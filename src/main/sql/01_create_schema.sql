BEGIN;

CREATE SCHEMA sto;
COMMENT ON SCHEMA sto IS 'Учёт автомобилей, записей на обслуживание, заказ-нарядов и запасных частей СТО';

SET search_path TO sto;


CREATE TABLE automobile (
    id                  SERIAL,
    vin                 CHAR(17)    NOT NULL,
    registration_number VARCHAR(15) NOT NULL,
    make                VARCHAR(50) NOT NULL,
    model               VARCHAR(60) NOT NULL,
    manufacture_year    SMALLINT    NOT NULL,
    CONSTRAINT automobile_pk PRIMARY KEY (id),
    CONSTRAINT automobile_vin_uk UNIQUE (vin),
    CONSTRAINT automobile_registration_uk UNIQUE (registration_number),
    CONSTRAINT automobile_vin_ck CHECK (vin ~ '^[A-HJ-NPR-Z0-9]{17}$'),
    CONSTRAINT automobile_registration_ck CHECK (registration_number ~ '^[0-9]{4} [ABEIKMHOPCTX]{2}-[1-8]$'),
    CONSTRAINT automobile_year_ck CHECK (manufacture_year BETWEEN 1980 AND 2030)
);

CREATE TABLE fault_type (
    id               SERIAL,
    code             VARCHAR(20)  NOT NULL,
    name             VARCHAR(100) NOT NULL,
    description      VARCHAR(255),
    vehicle_system   VARCHAR(100) NOT NULL,
    complexity_level SMALLINT     NOT NULL DEFAULT 1,
    CONSTRAINT fault_type_pk PRIMARY KEY (id),
    CONSTRAINT fault_type_code_uk UNIQUE (code),
    CONSTRAINT fault_type_code_ck CHECK (code ~ '^F-[0-9]{3}$'),
    CONSTRAINT fault_type_level_ck CHECK (complexity_level BETWEEN 1 AND 5)
);

CREATE TABLE service_post (
    id            SERIAL,
    post_number   VARCHAR(10)   NOT NULL,
    name          VARCHAR(100)  NOT NULL,
    post_type     VARCHAR(50)   NOT NULL,
    lift_capacity NUMERIC(8, 2) NOT NULL,
    CONSTRAINT service_post_pk PRIMARY KEY (id),
    CONSTRAINT service_post_number_uk UNIQUE (post_number),
    CONSTRAINT service_post_type_ck CHECK (post_type IN
        ('Диагностический', 'Ремонтный', 'Шиномонтажный', 'Электротехнический', 'Кузовной', 'Универсальный')),
    CONSTRAINT service_post_capacity_ck CHECK (lift_capacity BETWEEN 500 AND 10000)
);

CREATE TABLE workplace (
    id              SERIAL,
    zone_number     SMALLINT     NOT NULL,
    position_number SMALLINT     NOT NULL,
    equipment_type  VARCHAR(100) NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'available',
    CONSTRAINT workplace_pk PRIMARY KEY (id),
    CONSTRAINT workplace_position_uk UNIQUE (zone_number, position_number),
    CONSTRAINT workplace_number_ck CHECK (zone_number BETWEEN 1 AND 10 AND position_number BETWEEN 1 AND 20),
    CONSTRAINT workplace_status_ck CHECK (status IN ('available', 'occupied', 'maintenance'))
);

CREATE TABLE customer (
    id         SERIAL,
    first_name VARCHAR(60)  NOT NULL,
    last_name  VARCHAR(60)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    email      VARCHAR(100),
    CONSTRAINT customer_pk PRIMARY KEY (id),
    CONSTRAINT customer_phone_uk UNIQUE (phone),
    CONSTRAINT customer_email_uk UNIQUE (email),
    CONSTRAINT customer_phone_ck CHECK (phone ~ '^\+375 (17|25|29|33|44) [0-9]{3}-[0-9]{2}-[0-9]{2}$'),
    CONSTRAINT customer_email_ck CHECK (email ~ '^[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,}$')
);

CREATE TABLE spare_part (
    id              SERIAL,
    part_number     VARCHAR(30)    NOT NULL,
    name            VARCHAR(150)   NOT NULL,
    price           NUMERIC(10, 2) NOT NULL,
    stock_quantity  INTEGER        NOT NULL DEFAULT 0,
    warranty_months INTEGER        NOT NULL DEFAULT 0,
    CONSTRAINT spare_part_pk PRIMARY KEY (id),
    CONSTRAINT spare_part_number_uk UNIQUE (part_number),
    CONSTRAINT spare_part_number_ck CHECK (part_number ~ '^SP-[0-9]{4}$'),
    CONSTRAINT spare_part_price_ck CHECK (price > 0),
    CONSTRAINT spare_part_quantity_ck CHECK (stock_quantity >= 0),
    CONSTRAINT spare_part_warranty_ck CHECK (warranty_months BETWEEN 0 AND 60)
);


CREATE TABLE service_appointment (
    id               SERIAL,
    automobile_id    INTEGER        NOT NULL,
    service_post_id  INTEGER        NOT NULL,
    visit_date       DATE           NOT NULL,
    start_time       TIME           NOT NULL,
    end_time         TIME           NOT NULL,
    preliminary_cost NUMERIC(10, 2) NOT NULL DEFAULT 0,
    CONSTRAINT service_appointment_pk PRIMARY KEY (id),
    CONSTRAINT service_appointment_automobile_fk FOREIGN KEY (automobile_id) REFERENCES automobile (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_appointment_post_fk FOREIGN KEY (service_post_id) REFERENCES service_post (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_appointment_slot_uk UNIQUE (service_post_id, visit_date, start_time),
    CONSTRAINT service_appointment_cost_ck CHECK (preliminary_cost >= 0),
    CONSTRAINT service_appointment_time_ck CHECK (start_time < end_time),
    CONSTRAINT service_appointment_hours_ck CHECK (start_time >= '08:00' AND end_time <= '20:00')
);

CREATE TABLE service_order (
    id              SERIAL,
    appointment_id  INTEGER        NOT NULL,
    workplace_id    INTEGER        NOT NULL,
    customer_id     INTEGER        NOT NULL,
    status          VARCHAR(20)    NOT NULL DEFAULT 'new',
    processing_date DATE           NOT NULL DEFAULT CURRENT_DATE,
    work_type       VARCHAR(100)   NOT NULL,
    total_cost      NUMERIC(10, 2) NOT NULL DEFAULT 0,
    CONSTRAINT service_order_pk PRIMARY KEY (id),
    CONSTRAINT service_order_appointment_fk FOREIGN KEY (appointment_id) REFERENCES service_appointment (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_order_workplace_fk FOREIGN KEY (workplace_id) REFERENCES workplace (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_order_customer_fk FOREIGN KEY (customer_id) REFERENCES customer (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_order_status_ck CHECK (status IN ('new', 'in_progress', 'completed', 'paid', 'cancelled')),
    CONSTRAINT service_order_work_ck CHECK (work_type IN ('Диагностика', 'Техническое обслуживание',
        'Ремонт двигателя', 'Ремонт ходовой части', 'Ремонт тормозной системы', 'Автоэлектрика')),
    CONSTRAINT service_order_total_ck CHECK (total_cost >= 0),
    CONSTRAINT service_order_cancel_ck CHECK (status <> 'cancelled' OR total_cost = 0)
);

CREATE UNIQUE INDEX service_order_active_workplace_uk ON service_order (workplace_id)
    WHERE status IN ('new', 'in_progress');

CREATE TABLE automobile_fault (
    id            SERIAL,
    automobile_id INTEGER NOT NULL,
    fault_type_id INTEGER NOT NULL,
    detected_at   DATE    NOT NULL,
    is_primary    BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT automobile_fault_pk PRIMARY KEY (id),
    CONSTRAINT automobile_fault_automobile_fk FOREIGN KEY (automobile_id) REFERENCES automobile (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT automobile_fault_type_fk FOREIGN KEY (fault_type_id) REFERENCES fault_type (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT automobile_fault_occurrence_uk UNIQUE (automobile_id, fault_type_id, detected_at),
    CONSTRAINT automobile_fault_date_ck CHECK (detected_at >= '2000-01-01')
);

CREATE TABLE service_order_part (
    id               SERIAL,
    service_order_id INTEGER        NOT NULL,
    spare_part_id    INTEGER        NOT NULL,
    quantity         NUMERIC(10, 3) NOT NULL,
    unit_price       NUMERIC(10, 2) NOT NULL,
    line_total       NUMERIC(10, 2) NOT NULL,
    discount_amount  NUMERIC(10, 2) NOT NULL DEFAULT 0,
    CONSTRAINT service_order_part_pk PRIMARY KEY (id),
    CONSTRAINT service_order_part_order_fk FOREIGN KEY (service_order_id) REFERENCES service_order (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT service_order_part_part_fk FOREIGN KEY (spare_part_id) REFERENCES spare_part (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT service_order_part_pair_uk UNIQUE (service_order_id, spare_part_id),
    CONSTRAINT service_order_part_quantity_ck CHECK (quantity > 0),
    CONSTRAINT service_order_part_price_ck CHECK (unit_price >= 0),
    CONSTRAINT service_order_part_discount_ck CHECK (discount_amount >= 0 AND discount_amount <= quantity * unit_price),
    CONSTRAINT service_order_part_total_ck CHECK (line_total = round(quantity * unit_price - discount_amount, 2))
);


COMMENT ON TABLE automobile IS 'Автомобили, принятые на обслуживание';
COMMENT ON COLUMN automobile.id IS 'Код автомобиля (суррогатный ключ)';
COMMENT ON COLUMN automobile.vin IS 'Идентификационный номер VIN (17 символов)';
COMMENT ON COLUMN automobile.registration_number IS 'Регистрационный знак в формате 1234 AB-7';
COMMENT ON COLUMN automobile.make IS 'Марка';
COMMENT ON COLUMN automobile.model IS 'Модель';
COMMENT ON COLUMN automobile.manufacture_year IS 'Год выпуска';

COMMENT ON TABLE fault_type IS 'Справочник типов неисправностей';
COMMENT ON COLUMN fault_type.id IS 'Код типа неисправности (суррогатный ключ)';
COMMENT ON COLUMN fault_type.code IS 'Шифр неисправности вида F-001';
COMMENT ON COLUMN fault_type.name IS 'Название неисправности';
COMMENT ON COLUMN fault_type.description IS 'Описание признаков';
COMMENT ON COLUMN fault_type.vehicle_system IS 'Система автомобиля';
COMMENT ON COLUMN fault_type.complexity_level IS 'Уровень сложности устранения (1–5)';

COMMENT ON TABLE service_post IS 'Посты технического обслуживания';
COMMENT ON COLUMN service_post.id IS 'Код поста (суррогатный ключ)';
COMMENT ON COLUMN service_post.post_number IS 'Номер поста';
COMMENT ON COLUMN service_post.name IS 'Название поста';
COMMENT ON COLUMN service_post.post_type IS 'Тип поста';
COMMENT ON COLUMN service_post.lift_capacity IS 'Грузоподъёмность подъёмника, кг';

COMMENT ON TABLE workplace IS 'Рабочие места и оборудование СТО';
COMMENT ON COLUMN workplace.id IS 'Код рабочего места (суррогатный ключ)';
COMMENT ON COLUMN workplace.zone_number IS 'Номер зоны';
COMMENT ON COLUMN workplace.position_number IS 'Номер позиции в зоне';
COMMENT ON COLUMN workplace.equipment_type IS 'Тип оборудования';
COMMENT ON COLUMN workplace.status IS 'Статус: available – свободно, occupied – занято, maintenance – обслуживание';

COMMENT ON TABLE customer IS 'Клиенты станции технического обслуживания';
COMMENT ON COLUMN customer.id IS 'Код клиента (суррогатный ключ)';
COMMENT ON COLUMN customer.first_name IS 'Имя';
COMMENT ON COLUMN customer.last_name IS 'Фамилия';
COMMENT ON COLUMN customer.phone IS 'Телефон в формате +375 XX XXX-XX-XX';
COMMENT ON COLUMN customer.email IS 'Электронная почта; NULL – не указана';

COMMENT ON TABLE spare_part IS 'Запасные части, доступные для установки';
COMMENT ON COLUMN spare_part.id IS 'Код запасной части (суррогатный ключ)';
COMMENT ON COLUMN spare_part.part_number IS 'Артикул вида SP-0001';
COMMENT ON COLUMN spare_part.name IS 'Название запасной части';
COMMENT ON COLUMN spare_part.price IS 'Текущая цена за единицу, BYN';
COMMENT ON COLUMN spare_part.stock_quantity IS 'Остаток на складе';
COMMENT ON COLUMN spare_part.warranty_months IS 'Гарантийный срок, месяцев';

COMMENT ON TABLE service_appointment IS 'Записи автомобилей на обслуживание';
COMMENT ON COLUMN service_appointment.id IS 'Код записи (суррогатный ключ)';
COMMENT ON COLUMN service_appointment.automobile_id IS 'Записанный автомобиль';
COMMENT ON COLUMN service_appointment.service_post_id IS 'Пост обслуживания';
COMMENT ON COLUMN service_appointment.visit_date IS 'Дата визита';
COMMENT ON COLUMN service_appointment.start_time IS 'Время начала';
COMMENT ON COLUMN service_appointment.end_time IS 'Время окончания';
COMMENT ON COLUMN service_appointment.preliminary_cost IS 'Предварительная стоимость, BYN';

COMMENT ON TABLE service_order IS 'Заказ-наряды на обслуживание автомобилей';
COMMENT ON COLUMN service_order.id IS 'Код заказ-наряда (суррогатный ключ)';
COMMENT ON COLUMN service_order.appointment_id IS 'Запись на обслуживание';
COMMENT ON COLUMN service_order.workplace_id IS 'Рабочее место';
COMMENT ON COLUMN service_order.customer_id IS 'Клиент';
COMMENT ON COLUMN service_order.status IS 'Статус: new, in_progress, completed, paid, cancelled';
COMMENT ON COLUMN service_order.processing_date IS 'Дата оформления';
COMMENT ON COLUMN service_order.work_type IS 'Вид работ';
COMMENT ON COLUMN service_order.total_cost IS 'Итоговая стоимость (работы и запчасти), BYN';

COMMENT ON TABLE automobile_fault IS 'Выявленные неисправности автомобилей (связь M:N)';
COMMENT ON COLUMN automobile_fault.id IS 'Код записи (суррогатный ключ)';
COMMENT ON COLUMN automobile_fault.automobile_id IS 'Автомобиль';
COMMENT ON COLUMN automobile_fault.fault_type_id IS 'Тип неисправности';
COMMENT ON COLUMN automobile_fault.detected_at IS 'Дата выявления';
COMMENT ON COLUMN automobile_fault.is_primary IS 'Признак основной неисправности';

COMMENT ON TABLE service_order_part IS 'Строки состава заказ-нарядов (связь M:N)';
COMMENT ON COLUMN service_order_part.id IS 'Код строки (суррогатный ключ)';
COMMENT ON COLUMN service_order_part.service_order_id IS 'Заказ-наряд';
COMMENT ON COLUMN service_order_part.spare_part_id IS 'Запасная часть';
COMMENT ON COLUMN service_order_part.quantity IS 'Количество';
COMMENT ON COLUMN service_order_part.unit_price IS 'Цена детали на момент оформления заказ-наряда';
COMMENT ON COLUMN service_order_part.line_total IS 'Стоимость строки с учётом скидки';
COMMENT ON COLUMN service_order_part.discount_amount IS 'Сумма скидки';

COMMIT;
