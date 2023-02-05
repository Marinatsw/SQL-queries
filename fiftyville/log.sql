-- Keep a log of any SQL queries you execute as you solve the mystery.

-- What actually happened? We know that the street name is Fiftyville
SELECT description
  FROM crime_scene_reports
 WHERE year = 2021
       AND month = 7
       AND day = 28;

-- Created a report inside the file output.txt with crime details: Theft of CS50 Duck
-- From this report now we know:
-- 1. time = 10:15am,
-- 2. Place = Humphrey Street bakery,
-- 3. Number of witnesses = 3,
-- 4. Same detail = bakery
-- Going to check the witnesses interviews:

SELECT transcript
  FROM interviews
 WHERE year = 2021
       AND month = 7
       AND day = 28;

-- Going to check bakery security logs, ATM on Leggett Street transactions and
-- Airplane flights for earliest flight out of Fiftyville tomorrow (7.29.2021)

-- Let's check bakery security logs:

SELECT activity
  FROM bakery_security_logs
 WHERE year = 2021
       AND month = 7
       AND day = 28
       AND hour = 10;

-- Current query gives us "exit" and "entrance" logs, which is not that helpful.
-- We need to update that by adding in querry somthing like license plate

SELECT activity, license_plate
  FROM bakery_security_logs
 WHERE year = 2021
       AND month = 7
       AND day = 28
       AND hour = 10;

/*
| activity | license_plate |
+----------+---------------+
| entrance | R3G7486       |
| entrance | 13FNH73       |
| exit     | 5P2BI95       |
| exit     | 94KL13X       |
| exit     | 6P58WS2       |
| exit     | 4328GD8       |
| exit     | G412CB7       |
| exit     | L93JTIZ       |
| exit     | 322W7JE       |
| exit     | 0NTHK55       |
| exit     | 1106N58       |
| entrance | NRYN856       |
| entrance | WD5M8I6       |
| entrance | V47T75I          */

-- Much better, but range of 9 unic license plates is too big. Maybe there other way
-- Going to get the Name and passport number out of the license plate number

-- ATM on Leggett Street transactions:

SELECT account_number, transaction_type, amount
  FROM atm_transactions
 WHERE year = 2021
       AND month = 7
       AND day = 28
       AND atm_location = 'Leggett Street';

-- As a result we have list of account numbers and transaction types:
/*
| 28500762       | withdraw         | 48     |
| 28296815       | withdraw         | 20     |
| 76054385       | withdraw         | 60     |
| 49610011       | withdraw         | 50     |
| 16153065       | withdraw         | 80     |
| 86363979       | deposit          | 10     |
| 25506511       | withdraw         | 20     |
| 81061156       | withdraw         | 30     |
| 26013199       | withdraw         | 35  */

-- Next step is to check Phone

SELECT receiver, caller, duration
  FROM phone_calls
 WHERE year = 2021
       AND month = 7
       AND day = 28
       AND duration < 60;

/*
|    receiver    |     caller     | duration |
+----------------+----------------+----------+
| (996) 555-8899 | (130) 555-0289 | 51       |
| (892) 555-8872 | (499) 555-9472 | 36       |
| (375) 555-8161 | (367) 555-5533 | 45       |
| (717) 555-1342 | (499) 555-9472 | 50       |
| (676) 555-6554 | (286) 555-6063 | 43       |
| (725) 555-3243 | (770) 555-1861 | 49       |
| (910) 555-3251 | (031) 555-6622 | 38       |
| (066) 555-9701 | (826) 555-1652 | 55       |
| (704) 555-2131 | (338) 555-6650 | 54  */

-- Now we need to check the receiver buying a flight ticket for tommorow to Fiftyville:

-- Let'f find out the name of the car that were spotted near the bakery

SELECT bakery_security_logs.activity, bakery_security_logs.license_plate, people.name
  FROM people
  JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
       WHERE bakery_security_logs.year = 2021
         AND bakery_security_logs.month = 7
         AND bakery_security_logs.day = 28
         AND bakery_security_logs.hour = 10
         AND bakery_security_logs.minute >= 15
         AND bakery_security_logs.minute <= 25;

/*
| activity | license_plate |  name   |
+----------+---------------+---------+
| exit     | 5P2BI95       | Vanessa |
| exit     | 94KL13X       | Bruce   |
| exit     | 6P58WS2       | Barry   |
| exit     | 4328GD8       | Luca    |
| exit     | G412CB7       | Sofia   |
| exit     | L93JTIZ       | Iman    |
| exit     | 322W7JE       | Diana   |
| exit     | 0NTHK55       | Kelsey   */


-- Let's find out who's the Criminal by defining the bank account holders:

SELECT people.name, atm_transactions.transaction_type
  FROM people
  JOIN bank_accounts ON bank_accounts.person_id = people.id
  JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
 WHERE atm_transactions.year = 2021
   AND atm_transactions.month = 7
   AND atm_transactions.day = 28
   AND atm_transactions.atm_location = 'Leggett Street'
   AND atm_transactions.transaction_type = "withdraw";

/*
+---------+------------------+
|  name   | transaction_type |
+---------+------------------+
| Bruce   | withdraw         |
| Diana   | withdraw         |
| Brooke  | withdraw         |
| Kenny   | withdraw         |
| Iman    | withdraw         |
| Luca    | withdraw         |
| Taylor  | withdraw         |
| Benista | withdraw         |
+---------+------------------+ */

-- Some of this names are similar with the names of Car owners that visited bakery: Bruce, Diana, Iman

-- Let's check who's the Bruce, Diana and Iman from this people. Need to get the Name and Number of the caller


SELECT caller, caller_name, receiver, receiver_name
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND duration < 60;

/* Here is our callers: We can exclude Iman from the suspects,
But Bruce and Diana left
+----------------+-------------+----------------+---------------+
|     caller     | caller_name |    receiver    | receiver_name |
+----------------+-------------+----------------+---------------+
| (130) 555-0289 | Sofia       | (996) 555-8899 | Jack          |
| (499) 555-9472 | Kelsey      | (892) 555-8872 | Larry         |
| (367) 555-5533 | Bruce       | (375) 555-8161 | Robin         |
| (499) 555-9472 | Kelsey      | (717) 555-1342 | Melissa       |
| (286) 555-6063 | Taylor      | (676) 555-6554 | James         |
| (770) 555-1861 | Diana       | (725) 555-3243 | Philip        |
| (031) 555-6622 | Carina      | (910) 555-3251 | Jacqueline    |
| (826) 555-1652 | Kenny       | (066) 555-9701 | Doris         |
| (338) 555-6650 | Benista     | (704) 555-2131 | Anna          |
+----------------+-------------+----------------+-------------*/

-- Lest find out what's the first flight

-- Adding a new column to the flights table

UPDATE flights
   SET origin_airport_id = airports.city
  FROM airports
 WHERE flights.origin_airport_id = airports.id;

UPDATE flights
   SET destination_airport_id = airports.city
  FROM airports
 WHERE flights.destination_airport_id = airports.id;

SELECT id, hour, minute, origin_airport_id, destination_airport_id
  FROM flights
 WHERE year = 2021
   AND month = 7
   AND day = 29
 ORDER BY hour ASC
 LIMIT 1;

-- Resuming the known Destination airport, name, phone number and license plate
-- we're going to find out the Criminal

SELECT flights.destination_airport_id, name, phone_number, license_plate
  FROM people
  JOIN passengers ON people.passport_number = passengers.passport_number
  JOIN flights ON flights.id = passengers.flight_id
 WHERE flights.id = 36
 ORDER BY flights.hour ASC;

-- Now we can see that Bruce is showed more than Diana; Going to confirm that

SELECT name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN flights
    ON flights.id = passengers.flight_id
 WHERE (flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.id = 36)
   AND name IN
(SELECT phone_calls.caller_name
        FROM phone_calls
        WHERE year = 2021
        AND month = 7
        AND day = 28
        AND duration < 60)
   AND name IN
(SELECT people.name
        FROM people
        JOIN bank_accounts ON bank_accounts.person_id = people.id
        JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
       WHERE atm_transactions.year = 2021
         AND atm_transactions.month = 7
         AND atm_transactions.day = 28
         AND atm_transactions.atm_location = 'Leggett Street'
         AND atm_transactions.transaction_type = "withdraw")
         AND name IN
(SELECT people.name
        FROM people
        JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
       WHERE bakery_security_logs.year = 2021
         AND bakery_security_logs.month = 7
         AND bakery_security_logs.day = 28
         AND bakery_security_logs.hour = 10
         AND bakery_security_logs.minute >= 15
         AND bakery_security_logs.minute <= 25);