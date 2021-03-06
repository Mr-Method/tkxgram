#!/usr/bin/perl -w

use Modern::Perl;
use Data::Dumper;
use Crypt::OpenSSL::AES;
use Digest::SHA qw(sha1 sha256 hmac_sha512 hmac_sha1);
use Digest::MD5 qw(md5);
use PBKDF2::Tiny qw(derive);

# XXX refactor all *aes* together from MTProto.pm to TeleCrypt

sub aes_ige_dec
{
    my ($cypher, $key, $iv) = @_;
    my $aes = Crypt::OpenSSL::AES->new( $key );

    my $iv_c = substr( $iv, 0, 16 );
    my $iv_p = substr( $iv, 16, 16 );

    my $plain = '';

    for (my $i = 0; $i < length($cypher); $i += 16){
        my $c = substr($cypher, $i, 16);
        my $m = $aes->decrypt( $iv_p ^ $c ) ^ $iv_c;

        $iv_p = $m;
        $iv_c = $c;

        $plain .= $m;
    }

    return $plain;
}

sub gen_msg_key
{
    my ($self, $plain, $x) = @_;
    my $msg_key = substr( sha256(substr($self->{dcinstance}{permkey}{auth_key}, 88+$x, 32) . $plain), 8, 16 );
    return $msg_key;
}

sub gen_aes_key
{
    my ($auth_key, $msg_key, $x) = @_;
    my $sha_a = sha256( $msg_key . substr($auth_key, $x, 36) );
    my $sha_b = sha256( substr($auth_key, 40+$x, 36) . $msg_key );
    my $aes_key = substr($sha_a, 0, 8) . substr($sha_b, 8, 16) . substr($sha_a, 24, 8);
    my $aes_iv = substr($sha_b, 0, 8) . substr($sha_a, 8, 16) . substr($sha_b, 24, 8);
    return ($aes_key, $aes_iv);
}

# by AuthKey::prepareAES_oldmtp() from mtproto/auth_key.cpp
sub gen_aes_key_mt1
{
    my ($auth_key, $msg_key, $x) = @_;
    my $sha_a = sha1( $msg_key . substr($auth_key, $x, 32) );
    my $sha_b = sha1( substr($auth_key, 32+$x, 16) . $msg_key . substr($auth_key, 48+$x, 16) );
    my $sha_c = sha1( substr($auth_key, 64+$x, 32) . $msg_key );
    my $sha_d = sha1( $msg_key . substr($auth_key, 96+$x, 32) );
    my $aes_key = substr($sha_a, 0, 8) . substr($sha_b, 8, 12) . substr($sha_c, 4, 12);
    my $aes_iv = substr($sha_a, 8, 12) . substr($sha_b, 0, 8) . substr($sha_c, 16, 4) . substr($sha_d, 0, 8);
    return ($aes_key, $aes_iv);
}

# by mtproto/auth_key.h - send is false thus x=8
sub aesDecryptLocal {
    my ($enc_data, $auth_key, $key) = @_;
    my ($aes_key, $aes_iv) = gen_aes_key_mt1($auth_key, $key, 8 );
    my $plain = aes_ige_dec( $enc_data, $aes_key, $aes_iv );
}

# from SourceFiles/config.h
use constant {
    LocalEncryptIterCount => 4000, #  key derivation iteration count
    LocalEncryptNoPwdIterCount => 4, # key derivation iteration count without pwd (not secure anyway)
    LocalEncryptSaltSize => 32, # 256 bit
 };
use constant MAGIC => 'TDF$';

use Getopt::Long::Descriptive;

sub option_spec {
    [ 'settings|s=s' => 'name of settings file' ],
    [ 'map|m=s'      => 'name of map file' ],
    [ 'password|p=s' => 'local Telegram Desktop password' ],
    [ 'verbose|v:+' => 'more twitting about actions', { default => 0} ],
}

my ($opts, $usage);

eval { ($opts, $usage) = describe_options( '%c %o ...', option_spec() ) };
die "Invalid opts: $@\nUsage: $usage\n" if $@;

my ($LocalKey, $PassKey, $SettingsKey);

# sub derive {
#     my ( $type, $passwd, $salt, $iterations, $dk_length ) = @_;

# from SourceFiles/storage/localstorage.cpp
#    auto iterCount = pass.size() ? LocalEncryptIterCount : LocalEncryptNoPwdIterCount; // dont slow down for no password
#   PKCS5_PBKDF2_HMAC_SHA1(pass.constData(), pass.size(), (uchar*)salt->data(), salt->size(), iterCount, key.size(), (uchar*)key.data());
sub createLocalKey {
    my ($pass, $salt) = @_;
    my $iterCount = length $pass ? LocalEncryptIterCount : LocalEncryptNoPwdIterCount;

    return derive('SHA-1', $pass, $salt, $iterCount, 256);
}

sub decryptLocal {
    my ($encrypted, $auth_key) = @_;
    die "encrypted too short" if length $encrypted <= 16;
    die "bad encrypted part size"
        unless length($encrypted) % 16 == 0;

    my $enc_key = substr($encrypted, 0, 16, '');
    my $plain = aesDecryptLocal($encrypted, $auth_key, $enc_key);
    my $sha = sha1($plain);

    die "SHA1 of decrypted mismatched encryption key - incorrect password?"
        unless substr($sha, 0, 16) eq $enc_key;

    # XXX skip 4 bytes as in original?
    my $l = substr($plain, 0, 4, '');
    return $plain;
}

# slurp all file at once :)
sub readFile {
    my $fname = shift;
    open FH, '<', $fname
        or die "can't open $fname: $!";
    binmode FH;

    local $/ = undef;
    my $data = <FH>;
    close FH;

    die "too short file $fname" unless length $data > 40;

    my $magic = substr($data, 0, 4);
    die "wrong magic" unless $magic eq MAGIC;

    my $verdword = substr($data, 4, 4);
    my $ver = unpack 'V', $verdword;

    my $content = substr($data, 8);
    my $sign = substr $content, -16, 16, '';

    my $md5 = md5($content . pack('V', length $content) . $verdword . $magic);

    die "signature did not match" unless $md5 eq $sign;
    return $content;
}

sub readEncryptedFile {
    my $fname = shift;
    my $key = shift // $LocalKey;

    my $data = readFile($fname);
    # QByteArray encrypted;
    # result.stream >> encrypted;
    # EncryptedDescriptor data;
    # if (!decryptLocal(data, encrypted, key)) {
    my $blen = unpack('N', substr($data, 0, 4, ''));
    my $encrypted = substr($data, 0, $blen, '');

    die "trailing bytes in readEncryptedFile" if length $data;
    return decryptLocal($encrypted, $key);
}

sub read_settings {
    my ($content, $pass) = @_;

    #   QByteArray salt, settingsEncrypted;
    #   settingsData.stream >> salt >> settingsEncrypted;

    my $slen = unpack('N', substr($content, 0, 4, ''));
    warn "slen=$slen" if $opts->verbose;
    my $salt = substr($content, 0, $slen, '');

    #   if (salt.size() != LocalEncryptSaltSize) {
    #     LOG(("App Error: bad salt in settings file, size: %1").arg(salt.size()));
    #    return writeSettings();
    #   }

    die "salt size mismatch" unless $slen == LocalEncryptSaltSize;

    my $elen = unpack('N', substr($content, 0, 4, ''));
    warn "elen=$elen" if $opts->verbose;
    my $settingsEncrypted = substr($content, 0, $elen, '');

    die "read moar qt src..." if length $content;

    #   createLocalKey(QByteArray(), &salt, &SettingsKey);

    $SettingsKey = createLocalKey($pass//'', $salt);

    #   if (!decryptLocal(settings, settingsEncrypted, SettingsKey)) {

    return decryptLocal($settingsEncrypted, $SettingsKey); 
}

#   QByteArray salt, keyEncrypted, mapEncrypted;
#   mapData.stream >> salt >> keyEncrypted >> mapEncrypted;
#   if (salt.size() != LocalEncryptSaltSize) {
#    createLocalKey(pass, &salt, &PassKey);
#  EncryptedDescriptor keyData, map;
#    if (!decryptLocal(keyData, keyEncrypted, PassKey)) {
# XXX    auto key = Serialize::read<MTP::AuthKey::Data>(keyData.stream);
#        LocalKey = std::make_shared<MTP::AuthKey>(key);
#        if (!decryptLocal(map, mapEncrypted)) {
sub readMap {
    my ($content, $pass) = @_;

    my $slen = unpack('N', substr($content, 0, 4, ''));
    warn "slen=$slen" if $opts->verbose;
    my $salt = substr($content, 0, $slen, '');
    die "salt size mismatch" unless $slen == LocalEncryptSaltSize;

    my $klen = unpack('N', substr($content, 0, 4, ''));
    warn "klen=$klen" if $opts->verbose;
    my $keyEncrypted = substr($content, 0, $klen, '');

    $PassKey = createLocalKey($pass//'', $salt);

    $LocalKey = decryptLocal($keyEncrypted, $PassKey);

    my $mlen = unpack('N', substr($content, 0, 4, ''));
    warn "mlen=$mlen" if $opts->verbose;
    my $mapEncrypted = substr($content, 0, $mlen, '');

    die "trailing bytes in readMap" if length $content;

    return decryptLocal($mapEncrypted, $LocalKey);
}

die "for regular file map also must be specified beforehand"
    if not $opts->map and @ARGV;

my $output;
if (my $sn = $opts->settings) {
    $output = read_settings(readFile($sn), $opts->password);
}
elsif (my $mn = $opts->map) {
    $output = readMap(readFile($mn), $opts->password);
}
if (@ARGV) {
    $output = readEncryptedFile($ARGV[0]);
}

syswrite(STDOUT, $output);
