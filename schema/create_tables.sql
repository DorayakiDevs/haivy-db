--create the uuid random generate extension, (we had it installed but i'm doing it for asurance ;))
--create extension if not exist "pgcrypto";
-----------------------------------
-- account table 
create table AccountDetails(-- contains basic information of an account
  account_uid uuid references auth.users(id) on delete cascade,
  first_name varchar(50), -- can be null and dummy name is auto-generated
  last_name varchar(50), -- can be null and dummy name is auto-generated
  dob date, -- can be null
  profile_picrure text, -- can be null
  primary key (account_uid)
);
-----------------------------------
--patient table
create table Patient(
  patient_uid uuid primary key default gen_random_uuid(), 
  account_uid uuid,
  anonymous_status boolean default true, -- when a patient has an account, can be use to set visibility of patient information
  foreign key (account_uid) references auth.users(id)
);
-----------------------------------
--staff table
create table Staff(
  staff_id uuid primary key default gen_random_uuid(),
  account_uid uuid,
  foreign key (account_uid) references auth.users(id),
  role varchar(20),
  join_date date,
  status boolean  
);
-----------------------------------
--enum for status ticket/appointment
create type tik_status as enum('pending','booked', 'closed', 'canceled');
create type apt_status as enum('pending', 'scheduled', 'in progress', 'completed', 'canceled','no show');
create type ticket_type as enum('appointment', 'test', 'other');
--ticket table
create table Ticket(
  ticket_id uuid primary key default gen_random_uuid(),
  assigned_to uuid references Staff(staff_id),
  date_created timestamptz,
  ticket_type ticket_type,
  content text,
  status tik_status default 'pending'
);
-----------------------------------
--appointment table
create table Appointment(
  appointment_id uuid primary key default gen_random_uuid(),
  staff_id uuid,
  ticket_id uuid,
  patient_uid uuid,
  foreign key (staff_id) references Staff(staff_id), 
  foreign key (ticket_id) references Ticket(ticket_id),
  foreign key (patient_uid) references Patient(patient_uid),
  created_date date,
  meeting_date date,
  content text,
  visibility boolean,
  status apt_status default 'pending'
);
-----------------------------------
--Doctor specification 
create table Specification(
  specification_id uuid primary key default gen_random_uuid(),
  name varchar(50),
  achieved_date date,
  level integer
);
-- create type week_day as enum ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
-- create type session_day as enum ('Morning', 'Afternoon', 'Evening', 'Midnight');

create table DoctorSpecification(
  staff_id uuid,
  specification_id uuid,
  foreign key (staff_id) references Staff(staff_id),
  foreign key (specification_id)references Specification(specification_id),
  primary key (staff_id, specification_id)
);
-----------------------------------
--doctor schedule
create table DaySession(
  day_session varchar(20) primary key default gen_random_uuid(),
  start_time time,
  end_time time,
  location varchar(50),
  status boolean -- true for Available and false for Busy
);
create table WeekDay(
  day_of_week varchar(20),
  day_session varchar(20),
  primary key(day_of_week, day_session),
  foreign key(day_session) references DaySession(day_session)
);
create table DoctorSchedule(
  staff_id uuid references Staff(staff_id),
  day_of_week varchar(20),
  day_session varchar(20),
  primary key (staff_id, day_of_week, day_session),
  foreign key (day_of_week, day_session) references WeekDay(day_of_week, day_session)
);
-----------------------------------
-- --regimen ascociated
create type med_timing as enum ('empty stomach', 'before meal', 'with meal', 'after meal'); 
/*
explaination:
1.empty stomach ->  at least 1hr before meal or ~2hr after meal
2.before meal -> ~15-30min before meal
3.with meal -> taken together when having meal
4. after meal -> ~15-30min after a meal
the enums can be compared as numbered (ex: empty stomach < before meal)
*/
create table Medicine(
  medicine_id uuid primary key default gen_random_uuid(),
  name varchar(50),
  description text,
  is_available boolean,
  med_time med_timing
);
-----------------------------------
--prescription table
create table Prescription(
  prescription_id uuid primary key default gen_random_uuid(),
  name varchar(50),
  note text
);
create table PrescriptionDetail(
  prescription_detail_id uuid primary key default gen_random_uuid(),
  prescription_id uuid,
  medicine_id uuid,
  foreign key (prescription_id) references Prescription(prescription_id),
  foreign key (medicine_id) references Medicine(medicine_id),
  start_time timestamptz,
  end_time timestamptz,
  dosage float,
  interval integer,
  note text
);
-----------------------------------
-- customized regimen
create table CustomizedRegimen(
  cus_regimen_id uuid primary key default gen_random_uuid(),
  name varchar(50),
  description text,
  create_time date
);
create table CustomizedRegimenDetail(
  cus_regimen_detail_id uuid primary key default gen_random_uuid(),
  cus_regimen_id uuid,
  prescription_id uuid,
  foreign key (cus_regimen_id) references CustomizedRegimen(cus_regimen_id),
  foreign key (prescription_id) references Prescription(prescription_id),
  start_date date,
  end_date date,
  total_dosage float,
  frequency integer,
  note text
);
-----------------------------------
-- original regimen
create table Regimen(
  regimen_id uuid primary key default gen_random_uuid(),
  name varchar(50),
  create_date date,
  description text
);
create table RegimenDetail(
  regimen_detail_id uuid primary key default gen_random_uuid(),
  regimen_id uuid,
  medicine_id uuid,
  foreign key (regimen_id) references Regimen(regimen_id),
  foreign key (medicine_id) references Medicine(medicine_id),
  start_date date,
  end_date date,
  total_dosage float,
  frequency integer,
  note text
);
-----------------------------------
--patient medicine intake history
create table IntakeHistory(
  intake_id uuid primary key default gen_random_uuid(),
  user_id uuid,
  intake_time timestamptz,
  missed boolean,
  note text,
  created_date timestamptz default (now() AT TIME ZONE 'utc'::text)
);
