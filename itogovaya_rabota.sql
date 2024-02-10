Итоговый проект по обучению SQL.  Дата начала 18.12.2023. Нетология, группа sql-59.


1. Выведите название самолетов, которые имеют менее 50 посадочных мест?

select aircraft_code, max_kol_mest
from (select aircraft_code, count(seat_no) as max_kol_mest
	from seats s 
	group by aircraft_code) a
where max_kol_mest < 50

2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

select *, round (((sum1-(lag (sum1, 1) over (order by mes)))/(lag (sum1, 1) over (order by mes))*100), 2) as "% изменение"
from (select distinct mes, sum (total_amount) over (partition by mes) sum1 
from (select *, to_char (book_date, 'mm.yyyy') mes
from bookings b) p) ppp



3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

select *
from (select aircraft_code, array_agg(fare_conditions order by aircraft_code) kod
		from seats
		group by aircraft_code) s
where array_position (s.kod, 'Business') is null

4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
 В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.

with cte1 as (select f.flight_id, flight_no, actual_departure, actual_arrival, f.aircraft_code, departure_airport, arrival_airport, ticket_no, status, to_char (actual_departure, 'dd.mm.yyyy') daty, kol_mest
	from flights f
	full join boarding_passes bp on f.flight_id = bp.flight_id
	join (select aircraft_code, count(*) kol_mest 
	from seats	
	group by aircraft_code) pp on pp.aircraft_code = f.aircraft_code	
where ticket_no is null and (status ='Arrived' or status = 'Departed')),
cte2 as (
	select *, count (daty) over (partition by departure_airport, daty) kol
	from cte1
	)	
select departure_airport, aircraft_code, daty, kol_mest, sum (kol_mest) over (partition by departure_airport, daty order by actual_departure) itog_za_den
from cte2
where kol != 1 and kol is not null  and kol !=0

5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
 Выведите в результат названия аэропортов и процентное отношение.
 Решение должно быть через оконную функцию.


select distinct departure_airport, arrival_airport, (count (flight_id) over (partition by departure_airport, arrival_airport)) *100/  SUM(count (*)) over() "процент от общих полетов"
from flights		
group by flight_id



6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7

select distinct kod, count(kod) pas
from (select passenger_id, substring (cal,3,3) kod
from (select *, contact_data->> 'phone' cal
from tickets) pz1) pz2
group by kod


7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:

 До 50 млн - low
 От 50 млн включительно до 150 млн - middle
 От 150 млн включительно - high
 Выведите в результат количество маршрутов в каждом полученном классе

select distinct klass, count (marsh) over (partition by klass) kol_marsh
from 
(select distinct marsh, case
		when summa < 50000000 then 'low'
		when summa between 50000000 and 150000000 then 'middle'
		else 'high'
	end as klass
from (select tf.flight_id, departure_airport, arrival_airport, concat_ws('-', departure_airport, arrival_airport) marsh,  sum (amount) over (partition by departure_airport, arrival_airport) summa
from flights f
join ticket_flights tf on tf.flight_id = f.flight_id) kl) kl2
order by kol_marsh

8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых

select (select PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER by total_amount) FROM bookings) med_bron, (select PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER by amount) FROM ticket_flights) med_pereletov, round  ((select PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER by total_amount) FROM bookings)/(select PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER by amount) FROM ticket_flights), 2) "Отношение"

9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
  Для поиска расстояния между двумя точками на поверхности Земли используется модуль earthdistance.
  Для работы модуля earthdistance необходимо предварительно установить модуль cube.
  Установка модулей происходит через команду: create extension название_модуля.

with cte1 as (	
select distinct tf.flight_id, departure_airport, arrival_airport, concat_ws('-', departure_airport, arrival_airport) marsh, latitude as d_v, longitude as s_v, amount as sum
	from flights f
	join ticket_flights tf on tf.flight_id = f.flight_id
	join airports a on a.airport_code = f.departure_airport),
	cte2 as (
select flight_id,	departure_airport,	arrival_airport,	marsh,	d_v, s_v, sum, latitude as d_p, longitude as s_p
from cte1
join airports a on a.airport_code = cte1.arrival_airport),
	cte3 as (
select *, earth_distance (ll_to_earth (d_v, s_v), ll_to_earth (d_p, s_p)) distant
from cte2),
cte4 as (
select *, sum /(distant/1000) as km
from cte3)
select min (km)
from cte4

Пояснения:
Перелет, рейс - разовое перемещение самолета из аэропорта А в аэропорт Б.
Маршрут - формируется двумя аэропортами А и Б. При этом А - Б и Б - А - это разные маршруты.
Для решения заданий 8 и 9 необходимо самостоятельно использовать Документацию к PostgreSQL, так как в решении используются функции, которые не проходили в рамках обучения.


Автор: Недодел Роман тел. 8-963-212-76-53 (telegram @rojimand)

Объём времени на выполнение задачи 10 дней в среднем по 2 часа на задание в день. 
