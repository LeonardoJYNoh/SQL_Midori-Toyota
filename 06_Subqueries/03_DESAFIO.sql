-- EXERCÍCIOS ########################################################################

-- (Exercício 1) Crie uma coluna calculada com o número de visitas realizadas por cada
-- cliente da tabela sales.customers

with numero_visitas as(
	select 
		customer_id,
		count(*) as visitas
	from sales.funnel
	group by customer_id
)

select
	cus.*,
	num.visitas
from sales.customers as cus
left join numero_visitas as num
	on num.customer_id = cus.customer_id
order by num.visitas desc
