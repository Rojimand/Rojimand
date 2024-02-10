Задание

Дана структура таблиц:
https://u.netology.ru/backend/uploads/markdown_images/image/206762/unnamed.png

В какой СУБД мы будем работать — не сказано. По косвенным признакам предполагаем, что это PostgreSQL.

Задача 1
Необходимо получить список сотрудников в формате: «Иванова — Наталья – Юрьевна». 
ФИО должно быть прописано в одном столбике, разделение —.
Вывести: новое поле, назовем его fio, birth_dt.

select concat_ws('-', last_nm, first_nm, middle_nm) as fio, birth_dt 
from employees 

Задача 2
Вывести %% дозвона для каждого дня. Период с 01.10.2020 по текущий день 
(%% дозвона – это доля принятых звонков (dozv_flg=1) от всех поступивших звонков (dozv_flg = 1 or dozv_flg = 0)).
Вывести: date, sla (%% дозвона)

select  to_char(date, 'yyyy.mm.dd'), count(case when dozv_flg = '1' then 1 else 0 end) / count(*)
from calls
where  date between '2020.10.01' and now()
group by date


Задача 3
Дана таблица clinets:
id клиента
calendar_at - дата входа в мобильное приложение
Нужно написать запрос для расчета MAU.


--решение
select count(distinct id) MAU 
from clinets
where to_char(calendar_at, 'YYYY.MM') = '2024.01'-- в запросе указывается необходимый месяц	

