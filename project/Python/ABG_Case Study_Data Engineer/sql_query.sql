-- DROP database IF exists ABG_Case_Study_Data_Engineer;
USE ABG_Case_Study_Data_Engineer;
-- SELECT * FROM master_trip_data LIMIT 10;
 
DROP TABLE IF EXISTS transporter;
CREATE TABLE transporter(
Transporter_Id INT PRIMARY KEY AUTO_INCREMENT,
Transportor_Name VARCHAR(100)
);

DROP TABLE IF EXISTS driver;
CREATE TABLE driver(
Driver_Id INT PRIMARY KEY AUTO_INCREMENT,
Driver_Name VARCHAR(100)
);

DROP TABLE IF EXISTS aggregate_trip;
CREATE TABLE aggregate_trip(
`Vehicle_Number` VARCHAR(10), 
`Trip_No` VARCHAR(50), 
`Plant` VARCHAR(50),
 `Customer` VARCHAR(50),
 `Current_Location` VARCHAR(50), 
 `Running_Hours` double, 
 `Distance_Covered(Kms)`double,
 `Distance_Left(Kms)` double, 
 `Destination` VARCHAR(50), 
 `Actual_Day_And_Time_Of_Delivery` VARCHAR(50), 
 `Gate_In_Date_Time` VARCHAR(50),
 `DRIVER_ID` INT,
 `Transporter_Id` INT ,
 CONSTRAINT fk_driver FOREIGN KEY (Driver_Id) REFERENCES driver(Driver_Id),
 CONSTRAINT fk_transporter FOREIGN KEY (Transporter_Id) REFERENCES transporter(Transporter_Id)
 );
 
INSERT INTO transporter(Transportor_Name) select DISTINCT Transporter_Name from master_trip_data;
INSERT INTO driver(Driver_Name) select DISTINCT Driver_Name from master_trip_data;

INSERT INTO aggregate_trip(`Vehicle_Number`,`Trip_No`,`Plant`,`Customer`,`Current_Location`,`Running_Hours`, 
 `Distance_Covered(Kms)`,`Distance_Left(Kms)`, `Destination`, `Actual_Day_And_Time_Of_Delivery`, `Gate_In_Date_Time`,
 `DRIVER_ID`, `Transporter_Id`) SELECT `Vehicle_Number`,`Trip_No`,`Plant`,`Customer`,`Current_Location`,`Running_Hours`, 
 `Distance_Covered(Kms)`,`Distance_Left(Kms)`, `Destination`, `Actual_Day_And_Time_Of_Delivery`, `Gate_In_Date_Time`,
 `DRIVER_ID`, `Transporter_Id` FROM master_trip_data m LEFT JOIN driver d ON m.DRIVER_NAME=d.DRIVER_NAME 
 JOIN transporter t ON t.Transportor_Name = m.Transporter_Name;

-- SELECT * FROM aggregate_trip LIMIT 10;
-- SELECT * FROM transporter LIMIT 10;
-- SELECT * FROM driver LIMIT 10;





