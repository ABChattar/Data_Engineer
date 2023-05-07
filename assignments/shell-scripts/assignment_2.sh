#!/bin/bash
echo "********************************************"
echo "*     How many city you want to enter:-    *"
echo "********************************************"
read num
i=1
while [ $i -le $num ];
do
        echo "********************************************"
        echo "*             Enter city name              *"
        echo "********************************************"
        read city1
        if [[ $city1 =~ [0-9] ]];then
                echo "********************************************"
                echo "*  City name contains number enter again   *"
                echo "********************************************"
        else
                echo $city1 >> cities_s.txt
                let i++
        fi
done
echo "********************************************"
cat cities_s.txt
echo "********************************************"
sed -i 's/New/Old/gi' cities_s.txt
cat cities_s.txt | grep "Old" > old-cities.txt
cat old-cities.txt