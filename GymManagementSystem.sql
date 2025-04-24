-- Part01: Create A Database
DROP DATABASE IF EXISTS GymManagementSystem;
CREATE DATABASE GymManagementSystem;
USE GymManagementSystem;

-- Part02: Create Tables with Column Definitions

-- Members table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    join_date DATE NOT NULL,
    membership_status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    profile_picture VARCHAR(255)
);

-- Trainers table
CREATE TABLE Trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    specialization VARCHAR(150),
    certification VARCHAR(100),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2)
);

-- Membership Plans table
CREATE TABLE MembershipPlans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    description TEXT,
    duration_days INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- MemberMemberships table
CREATE TABLE MemberMemberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    auto_renew BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES MembershipPlans(plan_id)
);

-- Workouts table
CREATE TABLE Workouts (
    workout_id INT AUTO_INCREMENT PRIMARY KEY,
    workout_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration_minutes INT,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced'),
    trainer_id INT,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id)
);

-- MemberWorkouts table
CREATE TABLE MemberWorkouts (
    member_workout_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    workout_id INT NOT NULL,
    schedule_date DATE NOT NULL,
    schedule_time TIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-show') DEFAULT 'Scheduled',
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES Workouts(workout_id)
);

-- Equipment table
CREATE TABLE Equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL,
    description TEXT,
    purchase_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    status ENUM('Available', 'In Use', 'Maintenance', 'Retired') DEFAULT 'Available',
    condition_status ENUM('Excellent', 'Good', 'Fair', 'Poor', 'Broken') DEFAULT 'Good'
);

-- Payments table
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online Payment') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    membership_id INT,
    invoice_number VARCHAR(50),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (membership_id) REFERENCES MemberMemberships(membership_id)
);

-- Attendance table
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    check_in DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out DATETIME,
    workout_id INT,
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (workout_id) REFERENCES Workouts(workout_id)
);

-- PaymentLog table
CREATE TABLE PaymentLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    member_id INT,
    action VARCHAR(20),
    action_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2),
    old_status VARCHAR(20),
    new_status VARCHAR(20)
);

-- Part04: Create Indexes
CREATE INDEX idx_member_email ON Members(email);
CREATE INDEX idx_member_status ON Members(membership_status);
CREATE INDEX idx_payment_date ON Payments(payment_date);
CREATE INDEX idx_attendance_date ON Attendance(check_in);

-- Part05: Sequence Generator table
CREATE TABLE SequenceGenerator (
    sequence_name VARCHAR(50) PRIMARY KEY,
    next_value INT NOT NULL,
    increment_by INT NOT NULL DEFAULT 1
);

INSERT INTO SequenceGenerator (sequence_name, next_value, increment_by) 
VALUES ('invoice_sequence', 1000, 1);

-- Part06: Create Views
CREATE VIEW ActiveMembers AS
SELECT m.member_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name, 
       m.email, m.phone, mm.start_date, mm.end_date, mp.plan_name, m.membership_status
FROM Members m
JOIN MemberMemberships mm ON m.member_id = mm.member_id
JOIN MembershipPlans mp ON mm.plan_id = mp.plan_id
WHERE m.membership_status = 'Active' AND mm.end_date >= CURDATE();

CREATE VIEW MemberCheckIns AS
SELECT a.attendance_id, m.member_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       a.check_in, a.check_out, w.workout_name
FROM Attendance a
JOIN Members m ON a.member_id = m.member_id
LEFT JOIN Workouts w ON a.workout_id = w.workout_id;

-- Part07: Create Stored Procedures
DELIMITER //
CREATE PROCEDURE AddMember(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_plan_id INT,
    IN p_address VARCHAR(200)
)
BEGIN
    DECLARE v_member_id INT;
    DECLARE v_end_date DATE;
    DECLARE v_duration INT;
    DECLARE v_plan_exists INT DEFAULT 0;
    
    -- Check if plan exists and get duration
    SELECT COUNT(*), duration_days INTO v_plan_exists, v_duration
    FROM MembershipPlans 
    WHERE plan_id = p_plan_id;
    
    IF v_plan_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Membership plan not found';
    ELSE
        -- Insert the new member
        INSERT INTO Members (first_name, last_name, email, phone, join_date, address)
        VALUES (p_first_name, p_last_name, p_email, p_phone, CURDATE(), p_address);
        
        SET v_member_id = LAST_INSERT_ID();
        
        -- Calculate end date
        SET v_end_date = DATE_ADD(CURDATE(), INTERVAL v_duration DAY);
        
        -- Assign membership plan
        INSERT INTO MemberMemberships (member_id, plan_id, start_date, end_date)
        VALUES (v_member_id, p_plan_id, CURDATE(), v_end_date);
        
        -- Return the new member ID
        SELECT v_member_id AS new_member_id;
    END IF;
END //

CREATE PROCEDURE GetMemberWorkoutsProc(IN p_member_id INT)
BEGIN
    SELECT w.workout_name, mw.schedule_date, mw.schedule_time, mw.status
    FROM MemberWorkouts mw
    JOIN Workouts w ON mw.workout_id = w.workout_id
    WHERE mw.member_id = p_member_id
    ORDER BY mw.schedule_date DESC, mw.schedule_time DESC;
END //

CREATE PROCEDURE GetMemberDetails(IN p_member_id INT)
BEGIN
    -- Member basic info
    SELECT member_id, CONCAT(first_name, ' ', last_name) AS member_name, 
           email, phone, TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age
    FROM Members
    WHERE member_id = p_member_id;
    
    -- Member current membership
    SELECT mp.plan_name, mm.start_date, mm.end_date, 
           DATEDIFF(mm.end_date, CURDATE()) AS days_remaining
    FROM MemberMemberships mm
    JOIN MembershipPlans mp ON mm.plan_id = mp.plan_id
    WHERE mm.member_id = p_member_id AND mm.end_date >= CURDATE()
    LIMIT 1;
    
    -- Member recent workouts
    SELECT w.workout_name, a.check_in, a.check_out
    FROM Attendance a
    JOIN Workouts w ON a.workout_id = w.workout_id
    WHERE a.member_id = p_member_id
    ORDER BY a.check_in DESC
    LIMIT 5;
END //

CREATE PROCEDURE AddMemberCheckIn(
    IN p_member_id INT,
    IN p_workout_id INT
)
BEGIN
    INSERT INTO Attendance (member_id, check_in, workout_id)
    VALUES (p_member_id, NOW(), p_workout_id);
    
    SELECT LAST_INSERT_ID() AS new_attendance_id;
END //
DELIMITER ;

-- Part08: Create Functions
DELIMITER //
CREATE FUNCTION CalculateAge(date_of_birth DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE());
END //

CREATE FUNCTION GetNextInvoiceNumber() 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE next_val INT;
    
    UPDATE SequenceGenerator 
    SET next_value = next_value + increment_by 
    WHERE sequence_name = 'invoice_sequence';
    
    SELECT next_value INTO next_val 
    FROM SequenceGenerator 
    WHERE sequence_name = 'invoice_sequence';
    
    RETURN CONCAT('INV-', LPAD(next_val, 6, '0'));
END //
DELIMITER ;

-- Part09: Create Triggers
DELIMITER //
CREATE TRIGGER UpdateMembershipStatus
AFTER UPDATE ON MemberMemberships
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        UPDATE Members 
        SET membership_status = 'Inactive'
        WHERE member_id = NEW.member_id AND membership_status = 'Active';
    END IF;
END //

CREATE TRIGGER LogPaymentActivity
AFTER UPDATE ON Payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status <> OLD.payment_status THEN
        INSERT INTO PaymentLog (payment_id, member_id, action, amount, old_status, new_status)
        VALUES (NEW.payment_id, NEW.member_id, 'STATUS_CHANGE', NEW.amount, OLD.payment_status, NEW.payment_status);
    END IF;
END //

CREATE TRIGGER SetInvoiceNumberBeforePayment
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.invoice_number IS NULL THEN
        SET NEW.invoice_number = GetNextInvoiceNumber();
    END IF;
END //
DELIMITER ;