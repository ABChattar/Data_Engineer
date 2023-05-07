#!/bin/sh
echo "Enter city name"
read city1
echo "Enter the next city name"
read city2
echo "Enter the next city name"
read city3
echo "Enter the next city name"
read city4
touch cities_s.txt
echo $city1 >> cities_s.txt
echo $city2 >> cities_s.txt
echo $city3 >> cities_s.txt
echo $city4 >> cities_s.txt
cat cities_s.txt
sed -i 's/New/Old/gi' cities_s.txt
cat cities_s.txt | grep "Old" > old-cities.txt
cat old-cities.txt