# gym-management-dbms
## 1) Small Description of the Project/Application
The Gym Management System is a database-driven application designed to manage the daily operations of a fitness center efficiently. It maintains records of members, trainers, membership plans, workout schedules, payments, and attendance while ensuring data consistency and integrity. The system automates processes like membership tracking, trainer assignments, and invoice generation using SQL procedures, triggers, and functions.

## 2) Purpose of the Application
The primary goal of this application is to streamline gym operations by:
✅ Managing memberships: Track active/inactive members and their assigned plans.
✅ Handling trainer assignments: Assign trainers to workouts and packages.
✅ Tracking workout schedules: Schedule member workouts with specific trainers.
✅ Recording payments & invoices: Automate invoice generation and log payment transactions.
✅ Monitoring attendance: Keep records of member check-ins and workout completion.

This project provides an efficient, automated solution to replace manual record-keeping in a gym environment.

## 3) Structure of the Application - Users
The application involves different user roles:

👤 Gym Members - Enroll in membership plans, attend workouts, and make payments.
👤 Trainers - Conduct scheduled workouts and manage fitness programs.
👤 Admin/Receptionist - Manage members, trainers, packages, payments, and generate reports.

Each user interacts with the system using structured SQL queries, procedures, and views.

## 4) ER Diagram
📝 Entity-Relationship (ER) Diagram:
A well-designed ER model was created, consisting of entities like Members, Trainers, MembershipPlans, Payments, Workouts, and Attendance, with appropriate primary and foreign key relationships.

📌 (Attach ER Diagram Image Here)

## 5) Schema Objects in the Application
The application includes the following database schema objects:

📂 Tables
Members – Stores member details.

Trainers – Stores trainer details and specializations.

MembershipPlans – Stores membership plans and durations.

MemberMemberships – Links members to their plans.

Workouts – Stores details of workouts.

MemberWorkouts – Tracks scheduled workouts for members.

Equipment – Stores gym equipment details.

Payments – Manages member payments and invoices.

Attendance – Logs member check-ins and check-outs.

PaymentLog – Stores payment history for tracking.

📊 Views
ActiveMembers – Lists currently active members and their plans.

MemberCheckIns – Displays attendance records of members with workouts.

🛠 Triggers
UpdateMembershipStatus – Sets a member’s status to Inactive when their membership expires.

LogPaymentActivity – Logs changes in payment status.

SetInvoiceNumberBeforePayment – Assigns an invoice number before inserting a payment record.

🔄 Stored Procedures
AddMember – Registers a new member and assigns a membership plan.

GetMemberDetails – Fetches details like age, membership status, and workout history.

AddMemberCheckIn – Logs a check-in entry when a member attends a workout.

GetMemberWorkoutsProc – Retrieves scheduled workouts for a member.

📌 Functions
CalculateAge – Calculates a member’s age based on DOB.

GetNextInvoiceNumber – Generates a sequential invoice number for payments.

📦 Packages
GymMemberPkg – Groups procedures/functions related to member management.

BillingPkg – Manages payment and invoice-related operations.

WorkoutMgmtPkg – Handles workout scheduling and tracking.

🔢 Sequences
SequenceGenerator – Generates sequential values for invoices.

## 6) Loading the Data in Tables to Demonstrate the Functionality
To validate the system’s functionality, sample data was inserted into tables using SQL INSERT statements. The following actions were tested:

✔ Adding a new member
✔ Assigning a membership plan
✔ Scheduling a workout
✔ Logging attendance check-ins
✔ Processing payments and generating invoices

Example SQL Insertions:
sql
Copy
Edit
INSERT INTO Members (first_name, last_name, email, phone, join_date, address, date_of_birth, gender)
VALUES ('John', 'Doe', 'john.doe@example.com', '1234567890', SYSDATE, '123 Main St', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'Male');

INSERT INTO Payments (member_id, amount, payment_method, payment_status, membership_id)
VALUES (1, 299.99, 'Online Payment', 'Completed', 1);
✔ Stored procedures and functions were also executed to verify automation.

## 7) Database Design Applied (Normalization)
The Gym Management System follows Third Normal Form (3NF) to eliminate redundancy and ensure data integrity.

Normalization Applied:
✔ 1NF (First Normal Form):

Atomic values (e.g., first_name, last_name as separate fields).

No repeating groups.

✔ 2NF (Second Normal Form):

Non-key attributes depend entirely on primary keys (e.g., MemberMemberships ensures plan_id is linked properly).

✔ 3NF (Third Normal Form):

No transitive dependencies (e.g., Payments table stores only member_id, not additional details that belong in Members).

This normalization ensures efficient querying, reduces redundancy, and improves data consistency.

## 8) Conclusion
The Gym Management System successfully demonstrates the design and implementation of a fully functional database-driven application for managing gym operations. The project efficiently integrates SQL concepts like normalization, stored procedures, triggers, views, and sequences to ensure data consistency and automation.

By testing the system with real-world data, the functionality of membership management, trainer assignments, workout scheduling, and payment processing was verified. Automated invoice generation, attendance tracking, and dynamic membership status updates via triggers make the system robust.

This project not only showcases a well-structured relational database, but also lays the groundwork for potential future enhancements, such as front-end integration or API development.
