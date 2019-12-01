# [sqoop](http://sqoop.apache.org)

sqoop export \
--connect jdbc:mysql://localhost:16600/test \
--username root \
--password 123456 \
--table    customer_sell_report_month \
--columns  "in_month,market_department_id,market_department_name,market_id,deduct_amount_percent,pick_line_amount,pick_line_amount_percent,fly_amount,fly_amount_percent,delivery_line_amount,delivery_line_amount_percent,delivery_amount,delivery_amount_percent,created_by,updated_by" \
--hcatalog-database app \
--hcatalog-table customer_sale_report;