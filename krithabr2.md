# Критика протокола и оргподходов Telegram. Часть 2: организация, идеология, отношение к пользователям и т.д.

взять тикеты про /me и unread counter

telegra.ph

blocked users

pomogaesh drugim? etika zvezdy
prosto primerte na seb - avtory messenger pomogajut vam?
pomogat: etot podrazdel offtop, no daje karma habra pro eto, vdumajtes
lichn granitsy i kontslagere, feminist 100 let nazad i schas

like if was no MSDN - stary post pro Amazon vs Google, platforma, Joel Sun commodit

reply vs forward vs link - in nezygar etc.
ne vidno kto v bane


Alex Ф-ф-фэils!🌠︙, [25.10.19 12:45]
https://t.me/tginfo/2299 в тему "публичной" разработки


Vasily Terkin, [17.07.18 14:49]
Adel • 15 days ago

My telegram suddenly logged out and its connected in a number which i dont have that number anymore

Vasily Terkin, [17.07.18 14:49]
yep

Vasily Terkin, [17.07.18 14:50]
ради вашего удобства

Vadim Goncharov, [17.07.18 14:50]
прям так и вижу сгоревшую стойку, которую развернули из бэкапа


10.07 15:28 Vadim Goncharov: я смутно припоминаю, что часть инфы, типа апдейтов схем, рассылают по почте зарегавшимся разработчикам
10.07 15:28 Vasily: Апи хэш у меня есть
10.07 15:30 Vasily to Vadim Goncharov: Там нет поля для почты :)
10.07 15:30 Vasily: Соответственно, никаких писем я не получаю
10.07 15:31 Vasily to Vadim Goncharov: Ну при регистрации дают ID и токен
10.07 15:32 Vadim Goncharov: а как дают тогда?
10.07 15:32 Vadim Goncharov: НЕУЖЕЛИ ПО SMS?!
10.07 15:33 Vasily: Neecaque
10.07 15:34 Vadim Goncharov: то есть ты не регался
10.07 15:34 Vasily: Я не получил уже с пяток апдейтов схемы

Vasily Terkin, [13.04.18 23:47]
[Forwarded from Ciphernet]
В связи с проделками педерастов из администрации Telegram, и их политикой в отношении "spamblocked" users, чат будет существовать в виде приватного, во избежание потери доступа администраторов к управлению администраторами.  Также супергруппы, администраторы которых имеют spamblock, не выдаются в результатах поиска. (Попасть в permanent spamblock очень легко, достаточно чтобы вас несколько раз репортнули когда вы написали человеку первым в личку, или же не понравились одному из администраторов любого чата.)

 За инвайтом в чат писать @cyberjunta, сразу желательно указывать какой имеется опыт в программировании и для чего нужен чат. Старых участников пропускаем сразу.

Vadim Goncharov, [28.06.18 02:00]
кстати, форварднуть сообщение из секретного нельзя

но можно скопировать!


> повторим из первой части:

Vasily Terkin, [21.06.18 01:27]
О, я узнал, что такое IGE: IGE was the first attempt at an "authenticating encryption mode," originally for Kerberos. It was a failed attempt (it does not provide integrity protection), and had to be removed. That was the beginning of a 20 year quest for an authenticating encryption mode that works, which recently culminated in modes like OCB and GCM.

Vasily Terkin, [21.06.18 01:32]
А теперь аргументы со стороны телеги:

The team behind Telegram, led by Nikolai Durov, consists of six ACM champions, half of them Ph.Ds in math. It took them about two years to roll out the current version of MTProto.

Vasily Terkin, [21.06.18 01:35]
TelegramApp on Dec 16, 2013 [-]

The server now supports OAEP, although this has yet to find its way into the docs and clients. We will update. Thank you!

Vasily Terkin, [21.06.18 01:35]
Хехе, до сих пор едет

Vasily Terkin, [25.06.18 19:41]
Чот смешно. Два года на нижний уровень



Vasily Terkin, [15.12.17 23:06]
https://habrahabr.ru/post/206724/

Vasily Terkin, [15.12.17 23:27]
там в коментах шнайера цитируют

Vasily Terkin, [15.12.17 23:27]
Брюс Шнайер указывает наличие награды за взлом и пишет следующее:

    Объявление приза за взлом системы защиты вовсе не дает гарантии ее невзламываемости, и, как правило, означает, что разработчики не понимают, что следует сделать, чтобы показать, что система хорошо защищена.



# 3 часть


> это про ВК, но в телеге для старых так же

Vadim Goncharov, [08.10.18 02:01]
похоже, по функции получения списка диалогов, что нумерация id сквозная для всего меня! хотя дырки в нумерации всё равно возможны, наверное:

Если был передан параметр start_message_id, будет найдена позиция диалога в списке, идентификатор последнего сообщения которого равен start_message_id (или ближайший к нему более ранний). Начиная с этой позиции будет возвращено count диалогов. Смещение offset в этом случае будет отсчитываться от этой позиции (оно может быть отрицательным).

Vasily, [08.10.18 02:15]
API methods

    Documents in this section may be out of date.
        Please see the TDLib documentation or the open source code of our apps.

Vasily, [08.10.18 02:16]
Чо добавили


Vasily, [08.10.18 20:45]
Ах да, в 23-м слое нет каналов %)

Vasily, [08.10.18 20:45]
Т. Е. Каналы не документированы СОВСЕМ

Vasily, [08.10.18 20:55]
Да %)

Vasily, [08.10.18 20:55]
Кстати, getChannels возвращает Chats


Vasily, [08.10.18 21:09]
Тля, у запроса всё поменялось

Vasily, [08.10.18 21:09]
И нет доки

Vasily, [08.10.18 21:13]
Там теперь InputPeer

Vasily, [08.10.18 21:13]
Бля, вот нельзя было ростер сделать

Vadim Goncharov, [08.10.18 21:14]
а чем ростер отличается?

Vasily, [08.10.18 21:25]
Тем, что он есть, и есть всегда

Vasily, [08.10.18 21:25]
И в нём все сущности



Vadim Goncharov, [09.10.18 20:29]
democracy?..

Vasily, [09.10.18 20:30]
Какой-то флаг канала, хз

Vasily, [09.10.18 20:30]
Доков же нет :)

Vadim Goncharov, [09.10.18 20:30]
форбидден?

Vasily, [09.10.18 20:31]
Ваще хз

Vasily, [09.10.18 20:31]
Доков-то нет :)

Vadim Goncharov, [09.10.18 20:31]
демокраси, возможно, про открытую/закрытую группу

Vasily, [09.10.18 20:32]
Вот только это канал, как мы видим %)


 Vasily, [26.05.18 02:42]
 А за выбор webp я их уже проклинал, ага

 Vasily, [26.05.18 03:14]
 Да, есть media_photo, а есть media_document с флагом STICKER

 Vasily, [26.05.18 03:14]
 И IMAGE

 Vasily, [26.05.18 03:14]
 Да, у них отдельно photo, отдельно image

Vasily, [31.05.18 19:13]
SendMessage: ...entities MessageEntity...
MessageEntityBold: offset int, length int

Vasily, [31.05.18 19:14]
НУТЫПОНЕЛ

Vasily, [31.05.18 19:14]
Разметка отдельным списком
