-- (Query 1) Receita, leads, conversão e ticket médio mês a mês
-- Colunas: mês, leads (#), vendas (#), receita (k, R$), conversão (%), ticket médio (k, R$)

with 
	leads as (
		select
			date_trunc('month', visit_page_date)::date as visit_page_month,
			count(*) as visit_page_count
		from sales.funnel
		group by visit_page_month
		order by visit_page_month
		),


	payments as (
		select 
			date_trunc('month', fun.paid_date)::date as paid_month,
			count(fun.paid_date) as sales_count,
			sum(pro.price * (1 + fun.discount)) as revenue
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id
		where paid_date is not null
		group by paid_month
		order by paid_month
		)

select 
	leads.visit_page_month as "mês",
	leads.visit_page_count as "leads (#)",
	pay.sales_count as "vendas (#)",
	(pay.revenue/1000) as "receita (k, R$)",
	(pay.sales_count::float/leads.visit_page_count::float) as "conversão (%)",
	(pay.revenue * pay.sales_count)/1000 as "ticket médio (k, R$)"
from leads
left join payments as pay
	on pay.paid_month = leads.visit_page_month

-- (Query 2) Estados que mais venderam
-- Colunas: país, estado, vendas (#)


select
	'Brazil' as "país",
	cus.state as "estado",
	count(fun.paid_date) as "vendas (#)"
from sales.customers as cus
left join sales.funnel as fun
 on cus.customer_id = fun.customer_id
where paid_date between '2021-08-01' and '2021-08-31'
group by país, estado
order by "vendas (#)" desc
limit 5

-- (Query 3) Marcas que mais venderam no mês
-- Colunas: marca, vendas (#)

select
	pro.brand as "marca",
	count(paid_date) as "vendas (#)"
from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
where paid_date between '2021-08-01' and '2021-08-31'
group by brand
order by "vendas (#)" desc
limit 5

-- (Query 4) Lojas que mais venderam
-- Colunas: loja, vendas (#)

select 
	sto.store_name as loja,
	count(paid_date) as "vendas (#)"
from sales.funnel as fun
left join sales.stores as sto
	on fun.store_id = sto.store_id
where paid_date between '2021-08-01' and '2021-08-31'
group by loja
order by "vendas (#)" desc
limit 5

-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas (#)

select
	extract ('dow' from visit_page_date) as dia_semana,
	case 
		when extract ('dow' from visit_page_date)=0 then 'domingo'
		when extract ('dow' from visit_page_date)=1 then 'segunda'
		when extract ('dow' from visit_page_date)=2 then 'terça'
		when extract ('dow' from visit_page_date)=3 then 'quarta'
		when extract ('dow' from visit_page_date)=4 then 'quinta'
		when extract ('dow' from visit_page_date)=5 then 'sexta'
		when extract ('dow' from visit_page_date)=6 then 'sabado'
		else null
		end as "dia da semana",
	count(*) as "visitas (#)"
from sales.funnel
where visit_page_date between '2021-08-01' and '2021-08-31'
group by dia_semana
order by dia_semana

