Задание

Вы — аналитик данных. Руководитель дал вам задание поработать с таблицей logs действий пользователей 
(user_id, event, event_time, value). 

Действия пользователей поделены на сессии - последовательности событий, в которых между соседними по времени событиями промежуток не более 5 минут. 

Т.е. длина всей сессии может быть гораздо больше 5 минут, но между каждыми последовательными событиями не должно быть более 5 минут.

Поле event может принимать разные значения, в том числе ’template_selected’ (пользователь выбрал некий шаблон). 
В случае, если event=’template_selected’, то в value записано название этого шаблона 
(например, ’pop_art_style’).

Задача
Напишите SQL-запрос, выводящий 5 шаблонов, которые чаще всего применяются юзерами 2 и более раза подряд в течение одной сессии.


-- создаем ТЕСТ- таблицу
create table logs (
	user_id varchar(50),
	event varchar(50),
	event_time TIMESTAMP, 
	value varchar(50))



-- проверяем пустую таблицу
select *
from logs



-- добавляем множество записей с различными данными в таблицу
insert into logs (user_id, event, event_time, value)
values ('5', 'template_selected', '2022-06-16 20:44:00', 'proverka')





-- пишем SQL-запрос 
with
	cte1 as (select user_id, event, event_time, value, event_time-lag(event_time) over (partition by user_id, value order by event_time)  event_time2
			from logs2
			where event = 'template_selected'),
	cte2 as (select user_id, event,	event_time,	value,	event_time2, count(*) over (partition by user_id, value) as kol, count(*) over (partition by value) as kol2
			from cte1
			where event_time2 < '00:05:00')
select distinct value, kol, kol2
from cte2
where kol > 1
order by kol2 desc
limit 5



Этот запрос использует (CTE) для создания временных наборов данных и выполнения последующих операций. 
В первом CTE (`cte1`) производится вычисление значения `event_time2` - разницы во времени между каждой парой последовательных событий для каждого пользователя. Также происходит фильтрация по evet = 'template_selected'.
Затем, во втором CTE (`cte2`) происходит фильтрация только тех событий, где `event_time2` не превышает 5 минут и идет подсчет количества событий по 1 юзеру и группе шаблонов в сессиях меньше 5 минут, а так же общее количество раз выбранных шаблонов всеми пользователями.  
Далее, в основном запросе, выбираются уникальные значения из столбца `value` (шаблоны) из CTE `cte2`, фильтруются данные по условию вхождения в результат шаблонов 2 и более раза подряд в течение одной сессии каждым пользователем,  сортируется по убыванию количество выбранных шаблонов всеми пользователями и ограничивается результат до 5 строк с помощью оператора `limit`.

Таким образом, этот запрос возвращает первые 5 уникальных значений столбца `value` для событий "template_selected", где промежуток времени между событиями не превышает 5 минут и чаще всего применяются юзерами.
 
Автор: Недодел Роман тел. 8-963-212-76-53 (telegram @rojimand)

Объём времени на выполнение задачи 25 минут:
- 5 минтут на анализ логики построения задачи;
- 5 минут создать тест-таблицу и наполнить её данными;
- 15 минут сформировать запрос, оценить результаты и исправить исходный код при выявлении ошибки. 


