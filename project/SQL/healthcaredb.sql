/*================================================PROBLEM DOCUMENT 1==============================================================================

/*
Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows how the number of 
treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. 
*/
select count(*),v1.category from 
(select (case  
		when year(t1.date)-year(dob)<=14 then 'children'
		when year(t1.date)-year(dob)<=24  then 'youth'
		when year(t1.date)-year(dob)<=64  then 'adults'
		else 'senior citizen'		
	  end) "Category",p.patientid "patientid"
from patient p inner join treatment t1 on p.patientid = t1.patientid where year(t1.date)=2022) as v1 GROUP BY v1.Category;
/*
Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
Sort the data in a way that is helpful for Jimmy.
*/
SELECT v11.dname,v11.gender "Female",v11.Cnt,v22.gender "Male",v22.Cnt,v22.Cnt/v11.Cnt "Male to Female" FROM
(SELECT p.gender,v1.dname "dname",count(v1.dname) "Cnt" from person p join
(SELECT t.patientid 'pid' ,t.diseaseid 'did' ,d.diseasename 'dname' FROM treatment t JOIN disease d 
ON t.diseaseid=d.diseaseid) AS v1
ON p.personid=v1.pid  where p.gender='female'
GROUP BY p.gender,v1.did ) as v11
JOIN
(SELECT p.gender,v2.dname "dname",count(v2.dname) "Cnt" from person p join
(SELECT t.patientid 'pid' ,t.diseaseid 'did' ,d.diseasename 'dname' FROM treatment t JOIN disease d 
ON t.diseaseid=d.diseaseid) AS v2
ON p.personid=v2.pid 
WHERE p.gender='male' GROUP BY p.gender,v2.did) AS v22 ON v22.dname=v11.dname;

/*
Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, 
number of claims, and treatment-to-claim ratio. 
And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.
*/
SELECT v11.gender,v11.TCount,v22.CCount,v11.TCount/v22.CCount "ratio" FROM
(SELECT p.gender "gender",count(v1.did) "TCount" from person p join
(SELECT t.patientid 'pid' ,t.diseaseid 'did'  FROM treatment t ) AS v1
ON p.personid=v1.pid
GROUP BY p.gender)as v11
JOIN 
(SELECT p.gender "gender",count(v2.cid) "CCount" from person p join
(SELECT t.patientid 'pid',c.claimid 'cid' FROM treatment t join claim c on t.claimid = c.claimid ) AS v2
ON p.personid=v2.pid 
GROUP BY p.gender) as v22
ON v11.gender = v22.gender;

/*
Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.
*/
SELECT pharmacyname,count(v1.medicineID),sum(v1.maxprice),sum(v1.discount_price) FROM pharmacy INNER JOIN
(SELECT pharmacyid,medicineID,maxprice,maxprice- (maxprice*(discount/100)) "discount_price" FROM keep NATURAL JOIN medicine) AS v1
ON pharmacy.pharmacyid = v1.pharmacyid GROUP BY pharmacyname;

With cte as 
(SELECT pharmacyid,medicineID,maxprice,maxprice- (maxprice*(discount/100)) "discount_price" FROM keep NATURAL JOIN medicine)
SELECT pharmacyname,count(cte.medicineID),sum(cte.maxprice),sum(cte.discount_price) FROM pharmacy INNER JOIN cte
ON pharmacy.pharmacyid = cte.pharmacyid GROUP BY pharmacyname;
/*
Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines than others in a single 
prescription, for them, generate a report that finds for each pharmacy the maximum, minimum and average number of medicines 
prescribed in their prescriptions. 
*/
select pharmacyName, max(v1.qty) as _max,min(v1.qty) as _min  ,avg(v1.qty) as _avg from
(select distinct pharmacyID,prescriptionID,sum(quantity) over(partition by prescriptionID) "qty"
from contain natural join prescription) as v1 join pharmacy p on v1.pharmacyID=p.pharmacyID group by p.pharmacyName;
/*
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
/*
/*
===========================================================PROBLEM DOCUMENT 2 ==================================================================
*/
/*Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea that the 
pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number of prescriptions should
 exceed 100. Assist the company to identify those cities where the pharmacy can be set up.
*/
SELECT city,count(distinct pharmacyid),count( distinct prescriptionID) AS prescription_count,(count(distinct pharmacyid)/count( distinct prescriptionID)) AS ratio
 FROM prescription
natural join pharmacy natural join address
group by city having count(prescriptionID)>100 order by 2 desc;

/*
Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
For each city in their state, they need to identify the disease for which the maximum number of patients have gone for treatment. 
Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.
*/
-- select distinct b.city,b.diseaseName,max(b.dicease_count) over(partition by city) as patient_count
-- from(select state, city,pharmacyID,count(t.`patientID`) over(partition by `diseaseName`) as dicease_count ,diseaseName ,diseaseID
-- from disease
-- natural join treatment t
-- natural join prescription
-- natural join pharmacy
-- natural join address
-- where state='AL') b;

select DISTINCT city from address where state = 'AL';

create view view_a1 as Select * from
(select ad.city,dr.diseaseName, count(tr.patientId) as "cnt"
from address ad natural join person pr
inner join patient pa on pr.personId=pa.patientId
natural Join treatment tr
natural join disease dr where ad.state='AL'
group by ad.city,dr.diseaseName) as v1;

select city,diseaseName,cnt from view_a1 v
where cnt = (select max(cnt) from view_a1 where v.city = city);
/*

Problem Statement 3: The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, which was claimed the most and least for each disease.  
Assist to create such a report.
*/
DROP VIEW if exists VIEW_1;
CREATE VIEW VIEW_1 AS SELECT * FROM
(select diseasename,planname,count(planname)'CNT' from
(select * from disease natural join treatment natural join claim natural join InsurancePlan) AS v1  group by diseasename,planname)v11;
select * from view_1 where diseasename="Alzheimer's disease" and planname="Sukshma Hospi-Cash (Micro-Insurance Product)";
SELECT distinct *  FROM
(SELECT diseasename,
(select planname from VIEW_1 where diseasename=v_max.diseasename
and cnt = (select max(cnt) from VIEW_1 WHERE diseasename=v_max.diseasename limit 1) limit 1) MAX_COUNT from VIEW_1 as v_max) AS v11
NATURAL JOIN
(SELECT diseasename,
(select planname from VIEW_1 where diseasename=v_min.diseasename 
and cnt = (select min(cnt) from VIEW_1 WHERE diseasename=v_min.diseasename limit 1) limit 1) MIN_COUNT from VIEW_1 as  v_min) AS v22 ORDER BY 1;

 /*
 Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect multiple people in the 
 same household. For each disease find the number of households that has more than one patient with the same disease. 
Note: 2 people are considered to be in the same household if they have the same address. 
*/

DROP VIEW if exists VIEW_3;

CREATE VIEW VIEW_3 AS SELECT * FROM
(select diseasename,address1,count(address1)"cnt"  from disease
natural join treatment
natural join patient
inner join person on patient.patientid = person.personid
natural join address GROUP BY address1,diseasename having count(address1) >1) V1;

SELECT * FROM VIEW_3;

 SELECT DISTINCT  diseasename,
(select address1 from VIEW_3 where diseasename=v_max.diseasename 
and cnt = (select max(cnt) from VIEW_3 WHERE diseasename=v_max.diseasename limit 1) limit 1) MAX_COUNT from VIEW_3 as v_max;

/*
Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio 
between 1st April 2021 and 31st March 2022 (days both included). 
Assist them to create such a report.
*/
with cte as (select * from address natural join person inner join patient on patientid=personid natural join treatment t left join 
 claim c using (claimid))
select state,count(treatmentID),count(claimID),count(treatmentID)/count(claimID) "Ratio" from cte 
where date between '2021-04-1' and  '2022-03-31' group by state ;


/*
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
*/

/*
==========================================================PROBLEM DOCUMENT 3 =====================================================================
*/

/*
Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine that 
they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, wants to get a report of which 
pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to generate the report 
so that the pharmacies who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.  
*/ 
SELECT `pharmacyName`,COUNT(C.MEDICINEID) FROM pharmacy NATURAL JOIN PRESCRIPTION PR INNER JOIN CONTAIN C ON PR.PRESCRIPTIONID = C.PRESCRIPTIONID INNER JOIN
MEDICINE M ON C.MEDICINEID=M.MEDICINEID INNER JOIN TREATMENT T ON T.TREATMENTID=PR.TREATMENTID WHERE M.HOSPITALEXCLUSIVE='S'
 AND YEAR(T.DATE) IN(2021,2022) GROUP BY PR.PHARMACYID ORDER BY 2 desc;
/* 
Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. Generate a report that shows 
each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for.
*/
SELECT IP.PLANNAME,IC.COMPANYNAME ,COUNT(T.TREATMENTID) 'TREATMENTS COUNT'
FROM INSURANCEPLAN IP INNER JOIN INSURANCECOMPANY IC ON IP.COMPANYID=IC.COMPANYID
INNER JOIN CLAIM C ON C.UIN=IP.UIN INNER JOIN TREATMENT T ON T.CLAIMID=C.CLAIMID GROUP BY IP.PLANNAME,IC.COMPANYNAME;
/* 
Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. Generate a report that shows each 
insurance company's name with their most and least claimed insurance plans.
*/
create view view_4 as select * from
 (select distinct ic.companyName "companyName",ip.planName "planName", count(tr.claimId) over(partition by ic.companyName,ip.planName)
 as cnt
from InsuranceCompany ic natural join InsurancePlan ip
 natural join claim cl
natural join treatment tr
) as v1;


select vn2.companyName,vn2.planName,vn2.cnt,vn1.planName,vn1.cnt from
(select * from view_4 v where cnt = (select min(cnt) from view_4 where companyName=v.companyName)) as vn2 
inner join
(select * from view_4 v where cnt = (select max(cnt) from view_4 where companyName=v.companyName)) as vn1
on vn2.companyName=vn1.companyName;


select *,"min" from view_4 v where cnt = (select min(cnt) from view_4 where companyName=v.companyName)
union
select *,"max" from view_4 v where cnt = (select max(cnt) from view_4 where companyName=v.companyName);
/*
Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state requires more attention
 in the healthcare sector. Generate a report for them that shows the state name, number of registered people in the state, number 
 of registered patients in the state, and the people-to-patient ratio. sort the data by people-to-patient ratio. 
*/
SELECT DISTINCT(STATE),COUNT(P.PERSONID) "Count of Registered People",COUNT(PT.SSN) "Count of Registered Patient",
CONCAT("1:",1/ROUND(COUNT(PERSONID)/COUNT(PATIENTID),0)) as ratio FROM ADDRESS A INNER JOIN PERSON P 
ON A.ADDRESSID=P.ADDRESSID LEFT JOIN 
PATIENT PT ON PT.PATIENTID=P.PERSONID GROUP BY STATE ORDER BY COUNT(PERSONID) DESC,
COUNT(PATIENTID) DESC;
/*
Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the total quantity of 
medicine each pharmacy in his state has prescribed that falls under Tax criteria I for treatments that took place in 2021. 
Assist Jhonny in generating the report. 
*/
SELECT DISTINCT (A.STATE),P.PHARMACYNAME,SUM(K.QUANTITY) FROM KEEP K INNER JOIN PHARMACY P ON P.PHARMACYID=K.PHARMACYID 
JOIN ADDRESS A ON P.ADDRESSID=A.ADDRESSID JOIN MEDICINE M ON M.MEDICINEID=K.MEDICINEID JOIN PRESCRIPTION PR ON K.PHARMACYID=PR.PHARMACYID 
JOIN TREATMENT T ON T.TREATMENTID=PR.TREATMENTID 
 WHERE YEAR(T.DATE)=2021 AND M.TAXCRITERIA='I' AND state ='AZ' GROUP BY P.PHARMACYNAME, A.STATE ORDER BY 1;

/*

-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

*/
/*==========================================Problem 4==============================*/
/*
Problem Statement 1: 
“HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being displayed in numerical form, 
they want the product type in words. Also, they want to filter the medicines based on tax criteria. 
Display only the medicines of product categories 1, 2, and 3 for medicines that come under tax category I and medicines of product 
categories 4, 5, and 6 for medicines that come under tax category II. Write a SQL query to solve this problem.
ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
*/

select medicineID,productName,typeOfMedicine from(select medicineID,productName,
(case when productType =1 and taxCriteria ='I' then "Genric"
    when productType =2 and taxCriteria ='I' then "Patent"
    when productType =3 and taxCriteria ='I' then "Reference"
    when productType =4 and taxCriteria ='II' then "Similar"
    when productType =5 and taxCriteria ='II' then "New"
    when productType =6 and taxCriteria ='II' then "Specific"
    when productType =7   then "Biological"
    when productType =8  then "Dianamized"
     end)
as typeOfMedicine from medicine) v1
where typeOfMedicine is not null;




/*
Problem Statement 2:  
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription and if the total quantity of medicine is less 
than 20 tag it as “low quantity”. If the quantity of medicine is from 20 to 49 (both numbers including) tag it as “medium quantity“ and 
if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, and the Quantity tag for all the prescriptions 
issued by 'Ally Scripts'.
3 rows from the resultant table may be as follows:
prescriptionID	totalQuantity	Tag
1147561399		43			Medium Quantity
1222719376		71			High Quantity
1408276190		48			Medium Quantity
*/
SELECT DISTINCT(P.PRESCRIPTIONID),SUM(K.QUANTITY),COUNT(K.QUANTITY),
(CASE WHEN COUNT(K.QUANTITY)<20 THEN 'LOW QUANTITY'
WHEN COUNT(K.QUANTITY)<=49 THEN 'MEDIUM QUANTITY'
WHEN COUNT(K.QUANTITY)>=50 THEN 'HIGH QUANTITY' END) AS 'TAG' FROM KEEP K JOIN PRESCRIPTION P ON K.PHARMACYID=P.PHARMACYID JOIN PHARMACY PH
ON K.PHARMACYID=PH.PHARMACYID WHERE PH.PHARMACYNAME='Ally Scripts'
GROUP BY P.PRESCRIPTIONID;

/*
Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. The discount is considered “HIGH” if the discount rate on a product is 30% or higher, and the discount is considered “NONE” when the discount rate on a product is 0%.
 'Spot Rx' needs to find all the Low quantity products with high discounts and all the high-quantity products with no discount so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.
*/
 select medicineID,Q_tag,ProfitCriteria 
 from(select medicineID ,Q_tag,
 (case when Q_tag="Low Quantity" and discount>=30 then "high_discount"
 when   Q_tag="High Quantity" and discount=0 then "Zero_discount" end) as ProfitCriteria 
 from  
 (select medicineId,discount,
 (case when qty>7500 then "High Quantity" 
 when qty<1000 then "Low Quantity" end ) as Q_tag
 from
 (select distinct  medicineID,discount,
 sum(quantity) over(partition by medicineID)  as qty 
 from keep natural join pharmacy where pharmacyName="Spot Rx" ) v1)v2 )v3
 where Q_tag is not null and Profitcriteria is not null;
 
/*
Problem Statement 4: 

Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, hospital-exclusive medicines in the database.
Where affordable medicines are the medicines that have a maximum price of less than 50% of the avg maximum price of all the medicines in the database,
and costly medicines are the medicines that have a maximum price of more than double the avg maximum price of all the medicines in the database.
Mack wants clear text next to each medicine name to be displayed that identifies the medicine as affordable or costly. 
The medicines that do not fall under either of the two categories need not be displayed.
*/

select medicineID,productName,maxPrice , medicine_category from
(select m.medicineID as medicineID,m.productName as productName,m.maxPrice as maxPrice,(case when maxPrice<((select  avg(maxPrice) avg_price from medicine)*0.5) then "Affordable"
when maxPrice>((select  avg(maxPrice) avg_price from medicine)*2)  then "Costly" end) as medicine_category
from medicine m  join keep k  on m.medicineID=k.medicineID where k.pharmacyID=2301)v1 where medicine_category is not null;
 

/*
Problem Statement 5:  
The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.

Write a SQL query to list all the patient name, gender, dob, and their category.
*/
select p1.patientID,p.personName,p1.dob, ( case when p1.dob>='2005-01-01' and p.gender='male' then "YoungMale"
 when p1.dob>='2005-01-01' and p.gender='female' then "YoungFemale" 
 when p1.dob>='1985-01-01' and p1.dob<'2005-01-01' and  p.gender='male' then "AdultMale"
 when p1.dob>='1985-01-01' and p1.dob<'2005-01-01' and  p.gender='female' then "AdultFemale"
 when p1.dob>='1970-01-01' and p1.dob<'1985-01-01' and  p.gender='male' then "MidAgeMale"
 when p1.dob>='1970-01-01' and p1.dob<'2005-01-01' and  p.gender='female' then "MidAgeFemale"
 when p1.dob<'1970-01-01' and  p.gender='male' then "ElderMale"
 when p1.dob<'1970-01-01' and  p.gender='female' then "Elderfemale"
 end) as Person_Category
 from person p inner join patient p1 on p.personID=p1.patientID;

/*

/*

-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

*/
/* ******************************************    PROBLEM DOCUMENT 5       **************************************************************/
/*
Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. Help Johansson prepare a
 report that shows the patient's name, the number of treatments they have undergone, and their age, Sort the data in a way that
  the patients who have undergone more treatments appear on top.
*/
WITH cte as (SELECT p.personName,TIMESTAMPDIFF(YEAR,pa.dob,MAX(t.date))"age",count(treatmentid)"cnt" 
from person p inner join patient pa on p.`personID`=pa.`patientID` NATURAL join treatment t GROUP BY p.personName,pa.dob)
SELECT * from cte WHERE cnt >1 ORDER BY 3 DESC ;

select count(DISTINCT `personName`) from person;
/* 
Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain 
disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease how many males and females underwent treatment for 
each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio is also shown.
*/

SELECT v1.diseaseName,v1.gender,v1.Count,v2.gender,v2.Count,v1.Count/v2.Count "Ratio" FROM
(SELECT `diseaseName`,p2.gender"gender",COUNT(t.`diseaseID`) "Count"
from disease NATURAL JOIN treatment t INNER JOIN patient p ON t.`patientID`= p.`patientID`
INNER JOIN person p2 ON p.`patientID` = p2.`personID` WHERE year(t.`date`)= 2021 AND gender='male' GROUP BY `diseaseName`,p2.gender ) AS v1
INNER JOIN
(SELECT `diseaseName`,p2.gender"gender",COUNT(t.`diseaseID`) "Count"
from disease NATURAL JOIN treatment t INNER JOIN patient p ON t.`patientID`= p.`patientID`
INNER JOIN person p2 ON p.`patientID` = p2.`personID` WHERE year(t.`date`)= 2021 AND gender='female' GROUP BY `diseaseName`,p2.gender ) AS v2
ON v1.diseaseName=v2.diseaseName;
/*
Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, the top 3 cities that had the
 most number treatment for that disease.
Generate a report for Kelly’s requirement.
*/

SELECT * FROM
(WITH cte AS
(select d.diseaseName "dname", a.city ,count(t.diseaseId) as cnt
from address a natural join person pe
inner join patient p on pe.personID=p.patientId
natural join treatment t
natural join disease d
group by d.diseaseName,a.city)
select * , dense_rank() over (partition by cte.dname order by cnt desc) as drank from cte ) as v1 WHERE v1.drank <4;


select * from 
(select * , dense_rank() over (partition by v1.diseaseName order by cnt desc) as drank from
(select d.diseaseName, a.city ,count(t.diseaseId) as cnt
from address a natural join person pe
inner join patient p on pe.personID=p.patientId
natural join treatment t
natural join disease d
group by d.diseaseName,a.city) as v1) as v2 where v2.drank<4;
/*
Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not,For this purpose,
 she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed for each 
 disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement.
*/
SELECT v1.`pharmacyName`,v1.`diseaseName`,v1.2021_cnt,v2.2022_cnt FROM
(SELECT `pharmacyName`,`diseaseName`,COUNT(`prescriptionID`)"2021_cnt",ROW_NUMBER() OVER(ORDER BY pharmacyName)"rno"
FROM pharmacy NATURAL JOIN prescription NATURAL JOIN treatment NATURAL JOIN disease WHERE YEAR(date) = 2021 
GROUP BY pharmacyName,diseaseName) as v1
INNER JOIN
(SELECT `pharmacyName`,`diseaseName`,COUNT(`prescriptionID`)"2022_cnt",ROW_NUMBER() OVER(ORDER BY pharmacyName)"rno"
FROM pharmacy NATURAL JOIN prescription NATURAL JOIN treatment NATURAL JOIN disease WHERE YEAR(date) = 2022 
GROUP BY pharmacyName,diseaseName) as v2 USING(rno);
/*
Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company is targeting the 
patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more 
insurance of that company.
*/
SELECT `companyName`,`state`,COUNT(`claimID`) 
FROM address NATURAL JOIN insurancecompany NATURAL JOIN insuranceplan NATURAL JOIN claim
GROUP BY `companyName`,`state` ORDER BY 3 DESC;


/*
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/--- Problem Statement 6 -----/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
*/
/* 
Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed in 2022,
 total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the
  total medicine prescribed in 2022.
Order the result in descending order of the percentage found. 
*/
select pharmacyid,pharmacyname,count(*) "total count",count(if(hospitalexclusive='n',1,null)) "not hospital exclusive",
count(if(hospitalexclusive='s',1,null)) "hospital exclusive",(count(if(hospitalexclusive='s',1,null)) )/(count(if(hospitalexclusive='n',1,null)))*100 "percentage"
from pharmacy natural join prescription
natural join contain
natural join medicine
group by pharmacyname,pharmacyid;
/*
Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. She has requested a 
state-wise report of the percentage of treatments that took place without claiming insurance. Assist Sarah by creating a report as per 
her requirement.
*/
select a.state,count(*)
from treatment t left join claim c on t.claimid=c.claimid
left join patient p on t.patientid=p.patientid
left join person pe on p.patientid=pe.personid
left join address a on pe.addressid=a.addressid
where t.claimid IS NULL 
group by a.state;

/*
Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. Assist Sarah by 
creating a report which shows for each state, the number of the most and least treated diseases by the patients of that state in the year
 2022. 
*/

/*
Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city.
 Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients from that city 
 as well as the percentage of the patient with respect to the registered people.
*/
select a.city,count(p.patientid) "no. of patients",count(pe.personid) "no.of people",
(count(p.patientid)/count(pe.personid))*100 "patient:person percentage"
from address a left join person pe on a.addressid=pe.addressid
left join patient p on pe.personid=p.patientid
group by a.city
having count(*)>10
order by 1 ;
/*
Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects.
 Find the top 3 companies using the substance in their medicine so that they can be informed about it.
*/
select * from
 (select dense_rank() over(partition by companyname order by quantity desc) "denseno",quantity,m.companyname "cname"
 from keep join medicine m on keep.medicineid=m.medicineid where substancename='ranitidina'  )k 
 limit 3;

 select distinct companyname,dense_rank() over(order by quantity desc) from medicine inner join keep
where substancename='ranitidina' limit 3 ;

SELECT *,DENSE_RANK() OVER(ORDER BY qty DESC) FROM
(SELECT `companyName`,SUM(quantity)"qty" FROM  keep NATURAL JOIN medicine WHERE substancename='ranitidina' GROUP BY `companyName`) AS v LIMIT 3;


/*
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/- Problem Statement 7 -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
*/
/*
Problem Statement 1: 
Insurance companies want to know if a disease is claimed higher or lower than average.  Write a stored procedure that returns “claimed 
higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed disease is higher than the 
average return “claimed higher than average” otherwise “claimed lower than average”.
*/
DELIMITER $$
CREATE PROCEDURE `p_claims`(did int)
BEGIN
declare v1 int;
declare v2 int;
declare v3 int;
declare v4 int;
declare avg1 float;
declare avg2 float;
declare comment varchar(100);
select count(claimid)  into v1 from claim natural join treatment  ;
select count(diseaseid)  into v2 from disease ;
set avg1=v1/v2;
select count(claimid)  into v3 from claim natural join treatment  where diseaseid=did;
select count(diseaseid)  into v4 from disease  where diseaseid=did;
set avg2=v3/v4;
set comment=if(avg1>avg2,'claimed lower than average','claimed higher than average');
select comment;
END $$
DELIMITER ;

DROP PROCEDURE p_claims;
CALL p_claims(10)

select * from disease;

/*
Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease, if the number is 
same for both the genders, the value should be ‘same’.
*/
create view v_gender as(
select diseasename,count(if(pe.gender='male',1,null)) "number_of_male_treated",
count(if(pe.gender='female',1,null)) "number_of_female_treated"
from disease natural join treatment t
natural join patient p
join person pe on p.patientid=pe.personid
group by diseasename);

DELIMITER $$
CREATE PROCEDURE `p_gender`(did int)
BEGIN
select v_gender.diseasename,number_of_male_treated,number_of_female_treated,if(number_of_male_treated>number_of_female_treated,'male','female') "more_treated_gender"
 from v_gender join disease 
on v_gender.diseasename=disease.diseasename where diseaseid=did;
END $$
DELIMITER ;

CALL p_gender(10)
/*
Problem Statement 3:  
The insurance companies want a report on the claims of different insurance plans. 
Write a query that finds the top 3 most and top 3 least claimed insurance plans.
The query is expected to return the insurance plan name, the insurance company name which has that plan, and whether the plan is the most
 claimed or least claimed. 
*/
create view v_type_claim as(
 with cte_2 as
(select planname,companyname,
dense_rank() over(order by count(claimid) desc) "plan_claimed",
dense_rank() over(order by count(claimid) asc) "plan_claimed2"
 from insuranceplan natural join insurancecompany
 natural join claim
 natural join treatment
 group by companyname,planname)
 select planname,companyname, if(plan_claimed in (1,2,3) , "high_claim",null) "plan"
 from cte_2
 union
 select planname,companyname, if(plan_claimed2 in (1,2,3) , "least_claim",null) 
 from cte_2)
 ;

DELIMITER $$
CREATE PROCEDURE `p_type_claim`()
BEGIN
select * from  v_type_claim where plan is not null;
END $$
DELIMITER ;

CALL p_type_claim();
/*
Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
*/
create view v_category as (
 with cte_3 as (
 select diseasename , 
 case when p.dob>='2005-01-01' and pe.gender='male' then "YoungMale"
	when p.dob>='2005-01-01' and pe.gender='female' then "YoungFemale"
    when p.dob<'2005-01-01' and p.dob>= '1985-01-01'and pe.gender='male' then "AdultMale"
	when p.dob<'2005-01-01' and p.dob>= '1985-01-01'and pe.gender='female' then "AdultFemale"
	when p.dob<'1985-01-01' and p.dob>= '1970-01-01'and pe.gender='male' then "MidAgeMale"
	when p.dob<'1985-01-01' and p.dob>= '1970-01-01'and pe.gender='female' then "MidAgeFemale"
	when p.dob<'1970-01-01'and pe.gender='male' then "ElderMale"
    when p.dob<'1970-01-01'and pe.gender='female' then "ElderFemale"
    end "category"
from person pe join patient p on pe.personid=p.patientid
natural join treatment
natural join disease) 
select diseasename, count(*) over(partition by diseasename,category )"count",category 
from cte_3) ;

select diseasename,category,count(*)from v_category group by diseasename,category
 having count(*)>= any (select max(count) from v_category group by diseasename);
/*
Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName, description, 
maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. Write a query to find 
*/
select companyName, productName, description,maxprice,
case  when maxprice>1000 then 'pricey'
when maxprice<5 then 'affordable' end "m_category"
from medicine
where maxprice<5 or maxprice>1000
group by companyname, productName, description,maxprice
order by 1 desc;

/* ***********************************************************  PROBLEM DOCUMENT 9 ********************************************************/

/*
Problem Statement 1: 
Brian, the healthcare department, has requested for a report that shows for each state how many people underwent treatment for the disease
 “Autism”.  He expects the report to show the data for each state as well as each gender and for each state and gender combination. 
Prepare a report for Brian for his requirement.
*/
select state,count(*) "number of people",pe.gender
from address natural join person  pe
join patient p on p.patientid=pe.personid
natural join treatment
natural join disease
where diseasename='Autism' 
group by state,pe.gender
with rollup;

/*
Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for.
 The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) and if the report also 
 includes the total number of claims in the different years, as well as the total number of claims for each plan in all 3 years combined.
*/
select planname,companyname,year(date),count(*) "total no of claims"
from insuranceplan natural join insurancecompany
natural join claim 
natural join treatment
where year(date) in (2020,2021,2022)
group by planname,companyname,year(date)
with rollup;
/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows each state the number of the most and least treated diseases by the patients of that state
 in the year 2022. It would be helpful for Sarah if the aggregation for the different combinations is found as well. Assist Sarah to 
 create this report. 
*/

with cte_5 as(
select state,diseasename,count(*)  "count" 
from address natural join person pe
join patient p on p.patientid=pe.personid
natural join treatment
natural join disease
where year(date)=2022 
group by state,diseasename
with rollup
) 
select *
from cte_5 
group by count,state,diseasename;
-- order by 3
/*
Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions they have prescribed for each 
disease in the year 2022, along with this Jackson also needs to view how many prescriptions were prescribed by each pharmacy, and the 
total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. 
*/
create view v_123 as (
select pharmacyname,diseasename,count(*) "total_prescriptions"
from pharmacy natural join prescription
natural join treatment
natural join disease
group by diseasename,pharmacyname
with rollup);

create view v_234 as(
select pharmacyname,diseasename,count(prescriptionid) "no_of_prescriptions_2022"
from pharmacy natural join prescription
natural join treatment
natural join disease
where year(date)=2022
group by diseasename,pharmacyname
with rollup);

select v1.pharmacyname,v1.diseasename,v2.no_of_prescriptions_2022,v1.total_prescriptions from
v_123 v1 left join v_234 v2 on v1.pharmacyname=v2.pharmacyname and v1.diseasename=v2.diseasename;
/*
Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many males and females underwent treatment for each in the year 2022. 
It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. 
*/
select diseasename,COUNT(IF(gender = 'male', 1, null)) count_male,
    COUNT(IF(gender = 'female', 1, NULL)) count_female
from person pe join patient p on pe.personid=p.patientid
natural join treatment
natural join disease
where year(date)=2022
group by  diseasename
with rollup;

/*
-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
*/



/*
/* ***********************************************************  PROBLEM DOCUMENT 10 ********************************************************/

/*
Problem Statement 1:
The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
For this purpose, create a stored procedure that returns the performance of different insurance plans of an insurance company. 
When passed the insurance company ID the procedure should generate and return all the insurance plan names the provided company issues, 
the number of treatments the plan was claimed for, and the name of the disease the plan was claimed for the most. The plans which are 
claimed more are expected to appear above the plans that are claimed less.

*/

 delimiter $
create procedure pro_1(in id int)
begin
with cte as
(select planname,diseasename,count,if(rnk=1,'most','')highest from
(select planname,diseasename,count(claimid)count,
rank() over(partition by planname order by count(claimid) desc)rnk from insuranceplan 
natural join claim natural join treatment natural join disease where companyid=id group by planname,diseasename) t)
select planname,diseasename,total_claims,highest from
(select planname,sum(count) total_claims from cte group by 1)t1
natural join
(select planname,diseasename,highest from cte where highest='most')t2;
end $
delimiter ;

DROP PROCEDURE pro_1;
CALL pro_1(1118);


/*
Problem Statement 2:
It was reported by some unverified sources that some pharmacies are more popular for certain diseases. The healthcare department wants 
to check the validity of this report.
Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies the patients are preferring 
for the treatment of that disease in 2021 as well as for 2022.
Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a conclusion from the result.
*/
delimiter $
create procedure pro_100(in dname varchar(40))
begin
declare did int;
select diseaseid into did from disease where diseasename=dname;
select pharmacyname from
(select pharmacyname,count(treatmentid),row_number() over(order by count(treatmentid)desc)rnk 
from pharmacy natural join prescription natural join treatment natural join patient
 where year(date) in (2022,2021) and diseaseid=did group by pharmacyname)t where rnk<4;
end $
delimiter ;
call source('Asthma');
call source('Psoriasis');
drop procedure source;

/*
Problem Statement 3:
Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an insurance company or not.
Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio, the stored procedure should 
also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of the given state is less than the 
avg_insurance_patient_ratio then it Recommendation section can have the value “Recommended” otherwise the value can be “Not Recommended”.

Description of the terms used:
num_patients: number of registered patients in the given state
num_insurance_companies:  The number of registered insurance companies in the given state
insurance_patient_ratio: The ratio of registered patients and the number of insurance companies in the given state
avg_insurance_patient_ratio: The average of the ratio of registered patients and the number of insurance for all the states.
*/
delimiter $
create procedure pro_101(sname varchar(30))
begin
declare pc,cc,spc,scc int;
select count(*) into spc from patient inner join person on personid=patientid natural join address where state=sname;
select count(*) into scc from insurancecompany natural join address where state=sname;
select count(*) into pc from patient inner join person on personid=patientid natural join address;
select count(*) into cc from insurancecompany natural join address;
select if((pc/cc)<(spc/scc),'Not Recommended','Recommended')recommendation;
end $
delimiter ;
call pro_101('co');

/*
Problem Statement 4:
Currently, the data from every state is not in the database, The management has decided to add the data from other states and cities as well.
 It is felt by the management that it would be helpful if the date and time were to be stored whenever new city or state data is inserted.
The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that has four attributes. placeID, 
placeName, placeType, and timeAdded.
Description
placeID: This is the primary key, it should be auto-incremented starting from 1
placeName: This is the name of the place which is added for the first time
placeType: This is the type of place that is added for the first time. The value can either be ‘city’ or ‘state’
timeAdded: This is the date and time when the new place is added

You have been given the responsibility to create a system that satisfies the requirements of the management. Whenever some data is inserted in the Address table that has a new city or state name, the PlacesAdded table should be updated with relevant data. 
*/

create table placesadded(placeid int primary key auto_increment,placename varchar(20),
placetype varchar(20),timeadded datetime);
delimiter $
create trigger ad
before insert on address 
for each row
begin
if(new.city not in (select distinct city from address)) then
insert into placesadded(placename,placetype,timeadded) values (new.city,'city',now());
end if;
if(new.state not in (select distinct state from address)) then
insert into placesadded(placename,placetype,timeadded) values (new.state,'state',now());
end if;
end$
delimiter ;

/*
Problem Statement 5:
Some pharmacies suspect there is some discrepancy in their inventory management. The quantity in the ‘Keep’ is updated regularly and 
there is no record of it. They have requested to create a system that keeps track of all the transactions whenever the quantity of the 
inventory is updated.
You have been given the responsibility to create a system that automatically updates a Keep_Log table which has  the following fields:
id: It is a unique field that starts with 1 and increments by 1 for each new entry
medicineID: It is the medicineID of the medicine for which the quantity is updated.
quantity: The quantity of medicine which is to be added. If the quantity is reduced then the number can be negative.
For example:  If in Keep the old quantity was 700 and the new quantity to be updated is 1000, then in Keep_Log the quantity should be 300.
Example 2: If in Keep the old quantity was 700 and the new quantity to be updated is 100, then in Keep_Log the quantity should be -600.
*/

CREATE Table keep_log (
	id INT PRIMARY KEY AUTO_INCREMENT,
    medicineID INT,
	quantity INT
);

DELIMITER $$
CREATE TRIGGER trig_1
BEFORE UPDATE ON keep
FOR EACH ROW
BEGIN
DECLARE V1 INT;
set v1 = (SELECT quantity FROM keep WHERE `pharmacyID` = NEW.`pharmacyID` AND `medicineID` = NEW.`medicineID` AND quantity = NEW.quantity AND discount=NEW.discount limit 1);
INSERT INTO bcopy (medicineID,quantity) values (NEW.`medicineID`,NEW.quantity-v1);
END $$
DELIMITER ;

DROP TRIGGER trig_1;




/********************************************************* Problem 11***********************************/

--statement 1

delimiter $$
create procedure pb1101(in medid int)
BEGIN
select `pharmacyName`,phone from pharmacy join keep using(`pharmacyID`)
  where `medicineID` = medid and quantity > 0;
end $$
delimiter ;

call pb1101(4);
select * from keep order by 2;


--statement 2
DELIMITER $$
create Function pre_avg_func(pid int, st date, et date)
returns float DETERMINISTIC
BEGIN
DECLARE pre_avg float;
set pre_avg = (select avg(quantity*maxPrice) from pharmacy join prescription using(`pharmacyID`)
                join contain using(`prescriptionID`) join treatment using(`treatmentID`) join medicine 
                using(`medicineID`) where `pharmacyID`= pid and date BETWEEN st and et );

return pre_avg;
end $$
delimiter ;

select pre_avg_func(1145, '2021-01-01','2021-12-31') 'avg';
select * from pharmacy limit 10;

--statement 3

delimiter $$
create function m_dis_func(stat varchar(20),st date, et date )
returns varchar(50) DETERMINISTIC
begin
declare m_dis varchar(50);
set m_dis = (select diseaseName from address join person using(`addressID`)
            join patient on `personID` = `patientID` join treatment using(`patientID`)
            join disease using(`diseaseID`) where state = stat and date BETWEEN st and et
            group by `diseaseName` order by count(`treatmentID`) desc limit 1 );

return m_dis;
end $$
delimiter ;


select m_dis_func('DC','2021-01-01','2021-12-31');

select * from address;
 
--statement 4

delimiter $$
create FUNCTION treat_by_cdd(cit varchar(20), disid int, st date, et date)
returns int DETERMINISTIC
BEGIN
declare treat_count int;

set treat_count = (select count(`treatmentID`) from address join pharmacy using(`addressID`) 
                    join prescription using(`pharmacyID`) join treatment using(`treatmentID`)
                    join disease using(`diseaseID`) where city = cit and `diseaseID` = disid and date BETWEEN st and et);
return treat_count;
end $$
delimiter ;

select treat_by_cdd('Arvada', 1,'2021-01-01','2022-12-31') 'Treatments count';


--statement 5
delimiter $$
create function balance_audit(cmpid int)
returns FLOAT DETERMINISTIC
BEGIN
declare bal_avg int;
set bal_avg = (select avg(balance) from insuranceplan join claim using(uin) join treatment using(`claimID`) 
                where `companyID`=cmpid and date between '2022-01-01' and '2022-12-31' );

return bal_avg;
end$$
delimiter ;



select balance_audit(1118);




select @@sql_mode;
--set @@sql_mode = only_FULL_group_by;

select * from insurancecompany;
