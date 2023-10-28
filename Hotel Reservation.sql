

select * from HotelReservation..Hotel
--BookingID	Hotel	   BookingDate	             ArrivalDate	             LeadTime	Nights	Guests	DistributionChannel	 CustomerType	Country	     DepositType	AvgDailyRate	Status	       StatusUpdate	             Cancelled	Revenue	 RevenueLoss
--1	        Resort	    2014-07-24 00:00:00.000	2015-07-01 00:00:00.000	     342	     0	     2	      Direct	          Transient	    Portugal	    No Deposit	  0.00	         Check-Out	    2015-07-01 00:00:00.000	   0	       0.00	    0.00
--2	        Resort	    2013-06-24 00:00:00.000	2015-07-01 00:00:00.000	     737	     0	     2	      Direct	          Transient	    Portugal	    No Deposit	  0.00	         Check-Out	    2015-07-01 00:00:00.000	   0	       0.00	    0.00
--3	        Resort	    2015-06-24 00:00:00.000	2015-07-01 00:00:00.000	       7	     1	     1	      Direct	          Transient	    United Kingdom	No Deposit	  75.00	         Check-Out	    2015-07-02 00:00:00.000	   0	      75.00	    0.00

--There are 119,390 rows in the dataset. 
----------------------------------------------------------------------------------------------------------------------

--Checking if the BookingID column has duplicated values or not 
select count(distinct BookingID) as No_BookingID  from HotelReservation..Hotel 

--No_BookingID
--119390
-- No_BookingID = Total Number of Records in the dataset    (No Duplicated values)
-----------------------------------------------------------------------------------------------------------------------

--Specifying the min and max date 
select  min(ArrivalDate) as minarr, max(ArrivalDate) as maxarr
from HotelReservation..Hotel
--	     minarr                           	maxarr                
--	2015-07-01 00:00:00.000	    2017-08-31 00:00:00.000

select   min(ArrivalDate) as minarr, max(ArrivalDate) as maxarr
from HotelReservation..Hotel where DATEPART(yy,ArrivalDate) = 2016

--minarr	                  maxarr
--2016-01-01 00:00:00.000	2016-12-31 00:00:00.000
--The analysis will be for the year 2016
-------------------------------------------------------------------------------------------------------------------------

--Total Revenue for the year 2016 

Select SUM(Revenue) TotalRevenue
From HotelReservation..Hotel   Where DATEPART(yy,ArrivalDate) = 2016


--TotalRevenue	
--13303225.70	   
------------------------------------------------------------------------------------------------------------------------

--Monthly Total Revenue 
select DATEPART(MM,ArrivalDate) ArrivalMonth, Sum(Revenue) as Total_Revenue 
From HotelReservation..Hotel where DATEPART(yy,ArrivalDate)=2016 
Group by DATEPART(MM,ArrivalDate)  Order by Total_Revenue  Desc

--ArrivalMonth	Total_Revenue
--8	               1844836.15
--7	               1590291.05
--9	               1480759.14
--6	               1439152.88
--10	           1247601.84
--5	               1231884.13
--4	               1126280.09
--3	                919801.53
--11	            850531.67
--12	            701367.12
--2	                579198.72
--1	                291521.38

--The highest 4 values for Reveneue was in August, July, September and June. 

--------------------------------------------------------------------------------------------------------------------------

--Total Revenue by Country
select Top 5 Country, SUM(Revenue) as Total_Revenue
from HotelReservation..Hotel  where DATEPART(yy,ArrivalDate)=2016 Group by Country order by Total_Revenue Desc

--Country	        Total_Revenue
--Portugal	         3928589.33
--United Kingdom	 1834079.59
--France	         1499968.26
--Germany	         1035933.43
--Spain	              957749.35

--The most revenue is from customers who came from Portugal, United Kingdom, France, Gernamy and Spain.

-------------------------------------------------------------------------------------------------------------------------
--Total Revenue by DistributionChannel
select DistributionChannel, SUM(Revenue) as Total_Revenue
from HotelReservation..Hotel  Where DATEPART(yy,ArrivalDate)=2016  Group by DistributionChannel order by Total_Revenue Desc

--DistributionChannel	    Total_Revenue
--Online Travel Agent	     7562215.22
--Offline Travel Agent	     3440153.25
--Direct	                 1849005.04
--Corporate	                 451852.19

--Online Travel Agent channel  contributes in a big portion of the total revenue (i.e, most customers use online travel agent for their reservations).

------------------------------------------------------------------------------------------------------------------------------

--Average Daily Rate by month 
select  DATEPART(MM,ArrivalDate) ArrivalMonth, avg(AvgDailyRate) as AverageDailyRate
 from HotelReservation..Hotel   Where DATEPART(yy,ArrivalDate) =2016
 group by  DATEPART(MM,ArrivalDate)
 Order by  AverageDailyRate Desc

-- ArrivalMonth	  AverageDailyRate
--8	              142.8935
--7	              125.4845
--9	              114.7495
--6				  106.9773
--5	              96.3992
--10	          95.1117
--4	              88.9189
--12           	  86.3702
--11	          80.7375
--3	              79.0693
--2	              70.1022
--1	              64.7676
-- The highest Average Daily Rate (Average revenue earned for an occupied room on a given day) is for the months 8, 7, 9, and 6. 		

----------------------------------------------------------------------------------------------------------------------------------

--Cancellation Rate By Month 
with T1 as (select  DATEPART(MM,ArrivalDate) ArrivalMonth, count(Cancelled) As CancelledCount, (select count (*) from HotelReservation..Hotel where DATEPART(yy,ArrivalDate) =2016) as All_records
            from HotelReservation..Hotel   where Cancelled =0  and DATEPART(yy,ArrivalDate) =2016 group by  DATEPART(MM,ArrivalDate))
Select  ArrivalMonth, CancelledCount, All_records, Cast((((CancelledCount)/(All_records*1.0))*100) As Decimal (10,2)) as CancellationRate
From T1  Order By  CancellationRate Desc

--ArrivalMonth	CancelledCount	All_records	CancellationRate
--10	               3689	      56707	      6.51
--5	                   3563    	  56707	      6.28
--9	                   3372	      56707	      5.95
--4	                   3367	      56707	      5.94
--3	                   3347	      56707	      5.90
--8	                   3238	      56707	      5.71
--6	                   3196	      56707	      5.64
--7	                   3073	      56707	      5.42
--11	               2818	      56707	      4.97
--2	                   2554	      56707	      4.50
--12	               2462	      56707	      4.34
--1	                   1691	      56707	      2.98

--October showed up the highest cancellation rate followed by May.

------------------------------------------------------------------------------------------------------------------------------------

--Cancelation Rate based on LeadTime

with T1 as (select   Cancelled, case when LeadTime <= 30 Then '0-30 Days' Else '> 30 Days' End As LeadTimeCategories
           			from HotelReservation..Hotel   where Cancelled =0 and DATEPART(yy,ArrivalDate)=2016),
	T2 as (select LeadTimeCategories, Cast(((count(Cancelled)*1.0)/(select count (*) from HotelReservation..Hotel where DATEPART(yy,ArrivalDate)=2016)*100) AS Decimal (10,2)) as CancellationRate
            from T1   group by LeadTimeCategories )

select LeadTimeCategories, CancellationRate
from T2 order by LeadTimeCategories desc

--LeadTimeCategories	CancellationRate
--0-30 Days	            26.89
--> 30 Days             37.25

-- More than 30 days as lead time (no. of days between a guest books a room and the time the guest schedueled to arrive at 
-- the hotel) scored the highest cancellation rate. 	           
----------------------------------------------------------------------------------------------------------------------------------------

--Room Status By month 
Update HotelReservation..Hotel
set Status= 'No_Show'
    Where Status= 'No-Show'

Update HotelReservation..Hotel
set Status= 'Check_Out'
    Where Status= 'Check-Out'

SELECT [ArrivalMonth], Canceled,No_Show, Check_Out   FROM (select  DATEPART(MM,ArrivalDate) ArrivalMonth,
                         Status, COUNT(Status) As Count_Status
From HotelReservation..Hotel  Where DATEPART(yy,ArrivalDate)=2016 Group by DATEPART(MM,ArrivalDate), Status) as T1
 PIVOT (sum	(Count_Status)  for Status in (Canceled,No_Show, Check_Out)) As PivotTable

-- ArrivalMonth	  Canceled	 No_Show  	Check_Out
--1	                507	      50	     1691
--2	                1192	 145	     2554
--3	                1406	  71	     3347
--4	                2007	  54	     3367
--5	                1850	  65	     3563
--6	                2046	  50	     3196
--7	                1461	  38	     3073
--8	                1786	  39	     3238
--9	                1993	  29	     3372
--10	            2459	  55	     3689
--11	            1597	  39	     2818
--12	            1365	  33	     2462

--Most rooms are check out while there are still big proportion of rooms are being canceled. 
--The number of of rooms that are booked but the customers were not show up (No_Show) was inconsiderable.
--Most check out rooms were during October and May. 

 -------------------------------------------------------------------------------------------------------------------------------

 -- The most effective booking channels
select DistributionChannel, count(DistributionChannel) as ChannelCount
from HotelReservation..Hotel  Where DATEPART(yy,ArrivalDate)=2016  Group by DistributionChannel order by ChannelCount Desc

--DistributionChannel	ChannelCount
--Online Travel Agent	34358
--Offline Travel Agent	12258
--Direct	             6799
--Corporate	             3292

--Online Travel Agent channel plays a huge role in hotel reservation. The least effective channel in hotel reservation is the Corporate channel.

----------------------------------------------------------------------------------------------------------------------------------
--The most popular hotels 
select  Hotel, Number_of_Booking From(Select  Hotel, count(ArrivalDate) AS Number_of_Booking
                                           From HotelReservation..Hotel where DATEPART(yy,ArrivalDate)=2016 Group by Hotel)  AS T1 order by Number_of_Booking Desc

--Hotel	  Number_of_Booking
--City	    38140
--Resort	18567

--City hotels got much more customers compared to Resort hotels.

----------------------------------------------------------------------------------------------------------------------------------		

--Comparing hotels based on  Customer Type

Select CustomerType, City, Resort  
From (Select  Hotel, CustomerType, count(CustomerType) AS Number_Customer
                                           From HotelReservation..Hotel where DATEPART(yy,ArrivalDate)=2016 Group by Hotel, CustomerType) AS T1 
PIVOT (sum (Number_Customer)  for Hotel in (City, Resort )) As PivotTable  order by City desc , Resort desc


--CustomerType	     City	Resort
--Transient	        30298	14093
--Transient-Party	7600	3793
--Contract	         180	576
--Group	              62	105

--Transient is the main customer type, followed by Transient-Party and contract customer type. 
--City hotels is the most popular hotels for Transient and Transient-Party customers.
--However, Resort Hotel data show a higher portion Contract customer type at a total of 576, while the number for City Hotel only at 180.
--Group customer type is inconsiderable.

