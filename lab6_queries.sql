-- 1. Добавить внешние ключи. --
ALTER TABLE `dealer`
    ADD CONSTRAINT dealer_company_id_company_fk FOREIGN KEY (id_company)
        REFERENCES company (id_company)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

ALTER TABLE `order`
    ADD CONSTRAINT order_production_id_production_fk FOREIGN KEY (id_production)
        REFERENCES production (id_production)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT order_dealer_id_dealer_fk FOREIGN KEY (id_dealer)
        REFERENCES dealer (id_dealer)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT order_pharmacy_id_pharmacy_fk FOREIGN KEY (id_pharmacy)
        REFERENCES pharmacy (id_pharmacy)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

ALTER TABLE `production`
    ADD CONSTRAINT production_company_id_company_fk FOREIGN KEY (id_company)
        REFERENCES company (id_company)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    ADD CONSTRAINT production_medicine_id_medicine_fk FOREIGN KEY (id_medicine)
        REFERENCES medicine (id_medicine)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- 2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов. --
SELECT ph.name, `order`.date, `order`.quantity
FROM `order`
         INNER JOIN pharmacy ph ON `order`.id_pharmacy = ph.id_pharmacy
         INNER JOIN production pr ON `order`.id_production = pr.id_production
         INNER JOIN company c ON pr.id_company = c.id_company AND c.name = 'Аргус'
         INNER JOIN medicine m ON pr.id_medicine = m.id_medicine AND m.name = 'Кордеон';

-- 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января. --
SELECT m.name
FROM medicine m
         INNER JOIN production p ON m.id_medicine = p.id_medicine
         INNER JOIN company c ON p.id_company = c.id_company AND c.name = 'Фарма'
         LEFT JOIN `order` o ON p.id_production = o.id_production AND o.date < '2019-01-25'
WHERE o.id_order IS NULL;

-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов. --
SELECT c.name, MIN(p2.rating), MAX(p2.rating)
FROM company c
         INNER JOIN production p2 ON c.id_company = p2.id_company
         INNER JOIN `order` o ON p2.id_production = o.id_production
GROUP BY c.name
HAVING COUNT(o.id_order) >= 120;

/* 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
   Если у дилера нет заказов, в названии аптеки проставить NULL. */
SELECT d.name, p.name
FROM dealer d
         INNER JOIN company c ON d.id_company = c.id_company AND c.name = 'AstraZeneca'
         LEFT JOIN `order` o ON d.id_dealer = o.id_dealer
         LEFT JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy;

-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней. --
UPDATE medicine m
    INNER JOIN production p ON m.id_medicine = p.id_medicine AND p.price > 3000
SET p.price = p.price * 0.8
WHERE m.cure_duration <= 7;

-- 7. Добавить необходимые индексы. --
CREATE INDEX company_name_idx ON company (name);

CREATE INDEX medicine_name_idx ON medicine (name);

CREATE INDEX medicine_cure_duration_idx ON medicine (cure_duration);

CREATE INDEX production_price_idx ON production (price);

CREATE INDEX order_date_idx ON `order` (date);