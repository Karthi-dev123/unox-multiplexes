-- ============================================================
-- UNOX MULTIPLEXES
-- MYSQL 8.0.16+ VERSION (InnoDB, utf8mb4)
-- Converted from SQLite DDL
-- All 30 tables converted
-- ============================================================

CREATE DATABASE IF NOT EXISTS unox_multiplexes
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE unox_multiplexes;

-- ------------------------------------------------------------
-- 1. Screen_Class
-- ------------------------------------------------------------
CREATE TABLE Screen_Class (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL UNIQUE,
    ticket_price DECIMAL(10,2) NOT NULL,
    max_seats_per_screen INT NOT NULL,
    description TEXT,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_screen_class_price CHECK (ticket_price > 0),
    CONSTRAINT chk_screen_class_seats CHECK (max_seats_per_screen > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Screen
-- ------------------------------------------------------------
CREATE TABLE Screen (
    screen_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    screen_name VARCHAR(100) NOT NULL UNIQUE,
    total_seats INT NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_screen_total_seats CHECK (total_seats > 0),

    FOREIGN KEY (class_id)
        REFERENCES Screen_Class(class_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Seat
-- ------------------------------------------------------------
CREATE TABLE Seat (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    screen_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_row VARCHAR(5) NOT NULL,
    seat_column INT NOT NULL,
    seat_type VARCHAR(20) NOT NULL DEFAULT 'Regular',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_seat_column CHECK (seat_column > 0),
    CONSTRAINT chk_seat_type
        CHECK (seat_type IN ('Regular','Recliner','Wheelchair')),

    UNIQUE (screen_id, seat_number),
    UNIQUE (seat_id, screen_id),

    FOREIGN KEY (screen_id)
        REFERENCES Screen(screen_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Movie
-- ------------------------------------------------------------
CREATE TABLE Movie (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100) NOT NULL,
    rating VARCHAR(5) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Upcoming',
    language VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    release_date DATE NOT NULL,
    poster_image MEDIUMBLOB,
    description TEXT,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_movie_rating
        CHECK (rating IN ('U','UA','A','S')),
    CONSTRAINT chk_movie_status
        CHECK (status IN ('Upcoming','Running','Ended','Cancelled')),
    CONSTRAINT chk_movie_duration CHECK (duration_minutes > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Star_Cast
-- ------------------------------------------------------------
CREATE TABLE Star_Cast (
    cast_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    person_name VARCHAR(150) NOT NULL,
    role_in_movie VARCHAR(150) NOT NULL,
    person_type VARCHAR(20) NOT NULL,
    is_lead TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_star_cast_person_type
        CHECK (
            person_type IN (
                'Actor',
                'Director',
                'Producer',
                'Composer',
                'Cinematographer',
                'Writer'
            )
        ),

    FOREIGN KEY (movie_id)
        REFERENCES Movie(movie_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. Review_Team
-- ------------------------------------------------------------
CREATE TABLE Review_Team (
    reviewer_id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    address VARCHAR(500),
    phone VARCHAR(20),
    designation VARCHAR(100),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    joined_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. Movie_Review
-- ------------------------------------------------------------
CREATE TABLE Movie_Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    review_content TEXT NOT NULL,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rating_given DECIMAL(3,1) NOT NULL,
    is_published TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_review_rating
        CHECK (rating_given BETWEEN 0.0 AND 10.0),

    FOREIGN KEY (movie_id)
        REFERENCES Movie(movie_id),

    FOREIGN KEY (reviewer_id)
        REFERENCES Review_Team(reviewer_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. Show_Time
-- ------------------------------------------------------------
CREATE TABLE Show_Time (
    showtime_id INT AUTO_INCREMENT PRIMARY KEY,
    show_name VARCHAR(20) NOT NULL UNIQUE,
    start_time TIME NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_show_name
        CHECK (show_name IN ('Morning','Matinee','Evening','First Show'))
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. Movie_Schedule
-- ------------------------------------------------------------
CREATE TABLE Movie_Schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    showtime_id INT NOT NULL,
    schedule_date DATE NOT NULL,
    week_start_date DATE NOT NULL,
    end_time TIME NOT NULL,
    available_seats INT NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_schedule_available_seats CHECK (available_seats >= 0),

    UNIQUE (screen_id, showtime_id, schedule_date),
    UNIQUE (schedule_id, screen_id),

    FOREIGN KEY (movie_id)
        REFERENCES Movie(movie_id),

    FOREIGN KEY (screen_id)
        REFERENCES Screen(screen_id),

    FOREIGN KEY (showtime_id)
        REFERENCES Show_Time(showtime_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 10. Customer
-- ------------------------------------------------------------
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_customer_gender
        CHECK (gender IN ('Male','Female','Other') OR gender IS NULL)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 11. Membership
-- ------------------------------------------------------------
CREATE TABLE Membership (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    membership_number VARCHAR(50) NOT NULL UNIQUE,
    points_balance INT NOT NULL DEFAULT 0,
    total_points_earned INT NOT NULL DEFAULT 0,
    total_points_redeemed INT NOT NULL DEFAULT 0,
    membership_start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry_date DATE,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_membership_balance CHECK (points_balance >= 0),
    CONSTRAINT chk_membership_earned CHECK (total_points_earned >= 0),
    CONSTRAINT chk_membership_redeemed CHECK (total_points_redeemed >= 0),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 12. Booking
-- ------------------------------------------------------------
CREATE TABLE Booking (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    schedule_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    number_of_tickets INT NOT NULL,
    total_ticket_cost DECIMAL(10,2) NOT NULL,
    points_redeemed INT NOT NULL DEFAULT 0,
    discount_from_points DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    cancellation_reason VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_booking_tickets CHECK (number_of_tickets > 0),
    CONSTRAINT chk_booking_ticket_cost CHECK (total_ticket_cost >= 0),
    CONSTRAINT chk_booking_points CHECK (points_redeemed >= 0),
    CONSTRAINT chk_booking_discount CHECK (discount_from_points >= 0),
    CONSTRAINT chk_booking_total CHECK (total_amount >= 0),
    CONSTRAINT chk_booking_status
        CHECK (booking_status IN
            ('Pending','Confirmed','Cancelled','Expired')),

    UNIQUE (booking_id, schedule_id),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id),

    FOREIGN KEY (schedule_id)
        REFERENCES Movie_Schedule(schedule_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 13. Booking_Seat
-- ------------------------------------------------------------
-- SQLite used a partial unique index:
--     UNIQUE (schedule_id, seat_id) WHERE seat_status = 'Booked'
-- MySQL has no partial indexes, so a generated column is used instead:
-- active_seat_id = seat_id while 'Booked', NULL once 'Cancelled'.
-- UNIQUE indexes allow many NULLs, so cancelled rows never conflict.
CREATE TABLE Booking_Seat (
    booking_seat_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    schedule_id INT NOT NULL,
    screen_id INT NOT NULL,
    seat_id INT NOT NULL,
    seat_status VARCHAR(20) NOT NULL DEFAULT 'Booked',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    active_seat_id INT
        GENERATED ALWAYS AS (
            CASE WHEN seat_status = 'Booked' THEN seat_id ELSE NULL END
        ) STORED,

    CONSTRAINT chk_booking_seat_status
        CHECK (seat_status IN ('Booked','Cancelled')),

    UNIQUE (booking_id, seat_id),
    UNIQUE KEY UIX_ActiveSeatPerSchedule (schedule_id, active_seat_id),

    FOREIGN KEY (booking_id, schedule_id)
        REFERENCES Booking(booking_id, schedule_id),

    FOREIGN KEY (schedule_id, screen_id)
        REFERENCES Movie_Schedule(schedule_id, screen_id),

    FOREIGN KEY (seat_id, screen_id)
        REFERENCES Seat(seat_id, screen_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 14. Ticket
-- ------------------------------------------------------------
CREATE TABLE Ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_seat_id INT NOT NULL UNIQUE,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    ticket_price DECIMAL(10,2) NOT NULL,
    ticket_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_ticket_price CHECK (ticket_price > 0),
    CONSTRAINT chk_ticket_status
        CHECK (ticket_status IN ('Active','Used','Cancelled')),

    FOREIGN KEY (booking_seat_id)
        REFERENCES Booking_Seat(booking_seat_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 15. Payment_Gateway
-- ------------------------------------------------------------
CREATE TABLE Payment_Gateway (
    gateway_id INT AUTO_INCREMENT PRIMARY KEY,
    gateway_name VARCHAR(100) NOT NULL UNIQUE,
    gateway_code VARCHAR(50) NOT NULL UNIQUE,
    api_endpoint VARCHAR(500),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 16. Credit_Card_Info
-- ------------------------------------------------------------
CREATE TABLE Credit_Card_Info (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    card_holder_name VARCHAR(150) NOT NULL,
    card_number_masked VARCHAR(25) NOT NULL,
    card_type VARCHAR(20),
    expiry_month INT NOT NULL,
    expiry_year INT NOT NULL,
    gateway_token VARCHAR(255) NOT NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_card_type
        CHECK (
            card_type IN ('Visa','MasterCard','Amex','RuPay','Maestro')
            OR card_type IS NULL
        ),
    CONSTRAINT chk_card_expiry_month CHECK (expiry_month BETWEEN 1 AND 12),
    CONSTRAINT chk_card_expiry_year CHECK (expiry_year BETWEEN 2000 AND 2099),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 17. Food_Category
-- ------------------------------------------------------------
CREATE TABLE Food_Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_description TEXT,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 18. Food_Item
-- ------------------------------------------------------------
CREATE TABLE Food_Item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    size_variant VARCHAR(20) NOT NULL DEFAULT 'Regular',
    quantity_description VARCHAR(100),
    item_price DECIMAL(10,2) NOT NULL,
    calories INT,
    is_veg TINYINT(1) NOT NULL DEFAULT 1,
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_food_size_variant
        CHECK (size_variant IN
            ('Small','Medium','Large','Regular','Family')),
    CONSTRAINT chk_food_price CHECK (item_price >= 0),
    CONSTRAINT chk_food_calories CHECK (calories >= 0 OR calories IS NULL),

    FOREIGN KEY (category_id)
        REFERENCES Food_Category(category_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 19. Combo
-- ------------------------------------------------------------
CREATE TABLE Combo (
    combo_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    combo_name VARCHAR(150) NOT NULL,
    combo_description TEXT,
    combo_price DECIMAL(10,2) NOT NULL,
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_combo_price CHECK (combo_price > 0),

    FOREIGN KEY (category_id)
        REFERENCES Food_Category(category_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 20. Combo_Item
-- ------------------------------------------------------------
CREATE TABLE Combo_Item (
    combo_item_id INT AUTO_INCREMENT PRIMARY KEY,
    combo_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_combo_item_quantity CHECK (quantity > 0),

    UNIQUE (combo_id, item_id),

    FOREIGN KEY (combo_id)
        REFERENCES Combo(combo_id),

    FOREIGN KEY (item_id)
        REFERENCES Food_Item(item_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 21. Food_Order
-- ------------------------------------------------------------
CREATE TABLE Food_Order (
    food_order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    booking_id INT NULL,
    orderer_name VARCHAR(150),
    customer_id INT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_food_cost DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    is_seat_delivery TINYINT(1) NOT NULL DEFAULT 0,
    order_source VARCHAR(10) NOT NULL DEFAULT 'Online',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_food_order_cost CHECK (total_food_cost >= 0),
    CONSTRAINT chk_food_order_status
        CHECK (order_status IN
            ('Pending','Confirmed','Preparing','Delivered','Cancelled')),
    CONSTRAINT chk_food_order_source
        CHECK (order_source IN ('Online','QR')),

    FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 22. Food_Order_Item
-- ------------------------------------------------------------
CREATE TABLE Food_Order_Item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    food_order_id INT NOT NULL,
    item_id INT NULL,
    combo_id INT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_foi_quantity CHECK (quantity > 0),
    CONSTRAINT chk_foi_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_foi_subtotal CHECK (subtotal >= 0),
    -- exactly one of item_id / combo_id must be filled
    CONSTRAINT chk_foi_item_or_combo
        CHECK (
            (item_id IS NOT NULL AND combo_id IS NULL)
            OR
            (item_id IS NULL AND combo_id IS NOT NULL)
        ),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id),

    FOREIGN KEY (item_id)
        REFERENCES Food_Item(item_id),

    FOREIGN KEY (combo_id)
        REFERENCES Combo(combo_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 23. Booking_Payment
-- ------------------------------------------------------------
-- SQLite used a partial unique index (WHERE transaction_reference
-- IS NOT NULL). In MySQL a plain UNIQUE key already allows many
-- NULLs, so no workaround is needed.
CREATE TABLE Booking_Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NULL,
    food_order_id INT NULL,
    gateway_id INT NOT NULL,
    card_id INT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(100) NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_mode VARCHAR(20) NOT NULL,
    remarks VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_bp_amount CHECK (payment_amount > 0),
    CONSTRAINT chk_bp_status
        CHECK (payment_status IN
            ('Pending','Success','Failed','Refunded','PartialRefund')),
    CONSTRAINT chk_bp_mode
        CHECK (payment_mode IN
            ('CreditCard','DebitCard','NetBanking','UPI','UnoxWallet')),
    -- exactly one of booking_id / food_order_id must be filled
    CONSTRAINT chk_bp_booking_or_food
        CHECK (
            (booking_id IS NOT NULL AND food_order_id IS NULL)
            OR
            (booking_id IS NULL AND food_order_id IS NOT NULL)
        ),

    UNIQUE KEY UIX_Payment_TransactionReference (transaction_reference),

    FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id),

    FOREIGN KEY (gateway_id)
        REFERENCES Payment_Gateway(gateway_id),

    FOREIGN KEY (card_id)
        REFERENCES Credit_Card_Info(card_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 24. Payment_Exception
-- ------------------------------------------------------------
CREATE TABLE Payment_Exception (
    exception_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    booking_id INT NULL,
    food_order_id INT NULL,
    gateway_id INT NOT NULL,
    card_id INT NULL,
    exception_type VARCHAR(30) NOT NULL,
    exception_message TEXT NOT NULL,
    attempted_amount DECIMAL(10,2) NOT NULL,
    exception_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_resolved TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pe_type
        CHECK (exception_type IN (
            'InsufficientFunds',
            'CardExpired',
            'CVVMismatch',
            'GatewayError',
            'InvalidCard',
            'NetworkTimeout'
        )),
    CONSTRAINT chk_pe_amount CHECK (attempted_amount > 0),
    CONSTRAINT chk_pe_booking_or_food
        CHECK (
            (booking_id IS NOT NULL AND food_order_id IS NULL)
            OR
            (booking_id IS NULL AND food_order_id IS NOT NULL)
        ),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id),

    FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id),

    FOREIGN KEY (gateway_id)
        REFERENCES Payment_Gateway(gateway_id),

    FOREIGN KEY (card_id)
        REFERENCES Credit_Card_Info(card_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 25. Points_Transaction
-- ------------------------------------------------------------
CREATE TABLE Points_Transaction (
    points_txn_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_id INT NOT NULL,
    booking_id INT NULL,
    food_order_id INT NULL,
    transaction_type VARCHAR(10) NOT NULL,
    points_amount INT NOT NULL,
    transaction_amount DECIMAL(10,2) NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pt_type
        CHECK (transaction_type IN ('EARN','REDEEM')),
    CONSTRAINT chk_pt_points CHECK (points_amount > 0),
    CONSTRAINT chk_pt_amount
        CHECK (transaction_amount > 0 OR transaction_amount IS NULL),
    CONSTRAINT chk_pt_booking_or_food
        CHECK (
            (booking_id IS NOT NULL AND food_order_id IS NULL)
            OR
            (booking_id IS NULL AND food_order_id IS NOT NULL)
        ),

    FOREIGN KEY (membership_id)
        REFERENCES Membership(membership_id),

    FOREIGN KEY (booking_id)
        REFERENCES Booking(booking_id),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 26. QR_Code
-- ------------------------------------------------------------
CREATE TABLE QR_Code (
    qr_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE,
    qr_code_data VARCHAR(255) NOT NULL UNIQUE,
    qr_image MEDIUMBLOB,
    primary_delivery_method VARCHAR(20) NOT NULL DEFAULT 'App',
    whatsapp_sent TINYINT(1) NOT NULL DEFAULT 0,
    whatsapp_sent_at DATETIME NULL,
    app_downloaded TINYINT(1) NOT NULL DEFAULT 0,
    app_downloaded_at DATETIME NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_qr_delivery
        CHECK (primary_delivery_method IN ('WhatsApp','App')),

    FOREIGN KEY (ticket_id)
        REFERENCES Ticket(ticket_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 27. Entry_Log
-- ------------------------------------------------------------
CREATE TABLE Entry_Log (
    entry_log_id INT AUTO_INCREMENT PRIMARY KEY,
    qr_id INT NOT NULL,
    scan_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    scan_status VARCHAR(20) NOT NULL DEFAULT 'Success',
    scan_source VARCHAR(20) NOT NULL,
    scanned_by VARCHAR(100),
    entry_gate VARCHAR(50),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_el_status
        CHECK (scan_status IN ('Success','Failed','Duplicate','Expired')),
    CONSTRAINT chk_el_source
        CHECK (scan_source IN ('WhatsApp','App')),

    FOREIGN KEY (qr_id)
        REFERENCES QR_Code(qr_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 28. Food_Delivery
-- ------------------------------------------------------------
CREATE TABLE Food_Delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    food_order_id INT NOT NULL UNIQUE,
    seat_id INT NOT NULL,
    qr_id INT NULL,
    delivery_method VARCHAR(20) NOT NULL,
    delivery_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivered_at DATETIME NULL,
    delivered_by VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_fd_method
        CHECK (delivery_method IN ('QRScan','ManualSelect')),
    CONSTRAINT chk_fd_status
        CHECK (delivery_status IN
            ('Pending','InProgress','Delivered','Failed','Cancelled')),
    -- QRScan needs a qr_id, ManualSelect must not have one
    CONSTRAINT chk_fd_qr_required
        CHECK (delivery_method <> 'QRScan' OR qr_id IS NOT NULL),
    CONSTRAINT chk_fd_qr_forbidden
        CHECK (delivery_method <> 'ManualSelect' OR qr_id IS NULL),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id),

    FOREIGN KEY (seat_id)
        REFERENCES Seat(seat_id),

    FOREIGN KEY (qr_id)
        REFERENCES QR_Code(qr_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 29. Food_Order_Payment
-- ------------------------------------------------------------
CREATE TABLE Food_Order_Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    food_order_id INT NOT NULL,
    gateway_id INT NOT NULL,
    card_id INT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(100) NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_mode VARCHAR(20) NOT NULL,
    remarks VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_fop_amount CHECK (payment_amount > 0),
    CONSTRAINT chk_fop_status
        CHECK (payment_status IN
            ('Pending','Success','Failed','Refunded','PartialRefund')),
    CONSTRAINT chk_fop_mode
        CHECK (payment_mode IN
            ('CreditCard','DebitCard','NetBanking','UPI','UnoxWallet')),

    UNIQUE KEY UIX_Food_Order_Payment_TransactionReference (transaction_reference),

    FOREIGN KEY (food_order_id)
        REFERENCES Food_Order(food_order_id),

    FOREIGN KEY (gateway_id)
        REFERENCES Payment_Gateway(gateway_id),

    FOREIGN KEY (card_id)
        REFERENCES Credit_Card_Info(card_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 30. Audit_Log
-- ------------------------------------------------------------
CREATE TABLE Audit_Log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INT NOT NULL,
    action_type VARCHAR(10) NOT NULL,
    customer_id INT NULL,
    performed_by VARCHAR(100) NOT NULL,
    old_values TEXT,
    new_values TEXT,
    ip_address VARCHAR(45),
    session_id VARCHAR(100),
    action_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(500),

    CONSTRAINT chk_audit_action
        CHECK (action_type IN ('INSERT','UPDATE','DELETE','SELECT')),

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
) ENGINE=InnoDB;

-- ============================================================
-- VERIFY TABLES
-- ============================================================
SELECT table_name AS TABLE_NAME
FROM information_schema.tables
WHERE table_schema = 'unox_multiplexes'
ORDER BY table_name;

SELECT COUNT(*) AS TotalTables          -- expect 30
FROM information_schema.tables
WHERE table_schema = 'unox_multiplexes';
