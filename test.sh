#!/bin/bash

# API and database settings
API_KEY="YOUR_API_KEY_HERE"
BASE_URL="http://apis.data.go.kr/B552657/ErmctInfoInqireService"
DB_HOSTNAME="localhost"
DB_USER="your_username"
DB_PASS="your_password"
DB_NAME="emergency_db"

# Function to fetch data from the API and insert into the database
fetch_and_insert_data() {
    endpoint=$1
    response=$(curl -s "${BASE_URL}/${endpoint}?serviceKey=${API_KEY}&pageNo=1&numOfRows=100")

    echo "$response" | xmllint --format - | grep -E "(<hpid>|<dutyName>|<dutyAddr>|<dutyTel3>|<wgs84Lat>|<wgs84Lon>|<availableBed>|<hvec>|<hvoc>)" | while read -r line; do
        case "$line" in
            *"<hpid>"*)
                hpid=$(echo "$line" | sed -E 's/.*<hpid>([^<]+)<\/hpid>.*/\1/')
                ;;
            *"<dutyName>"*)
                dutyName=$(echo "$line" | sed -E 's/.*<dutyName>([^<]+)<\/dutyName>.*/\1/')
                ;;
            *"<dutyAddr>"*)
                dutyAddr=$(echo "$line" | sed -E 's/.*<dutyAddr>([^<]+)<\/dutyAddr>.*/\1/')
                ;;
            *"<dutyTel3>"*)
                dutyTel3=$(echo "$line" | sed -E 's/.*<dutyTel3>([^<]+)<\/dutyTel3>.*/\1/')
                ;;
            *"<wgs84Lat>"*)
                wgs84Lat=$(echo "$line" | sed -E 's/.*<wgs84Lat>([^<]+)<\/wgs84Lat>.*/\1/')
                ;;
            *"<wgs84Lon>"*)
                wgs84Lon=$(echo "$line" | sed -E 's/.*<wgs84Lon>([^<]+)<\/wgs84Lon>.*/\1/')
                ;;
            *"<availableBed>"*)
                availableBed=$(echo "$line" | sed -E 's/.*<availableBed>([^<]+)<\/availableBed>.*/\1/')
                ;;
            *"<hvec>"*)
                hvec=$(echo "$line" | sed -E 's/.*<hvec>([^<]+)<\/hvec>.*/\1/')
                ;;
            *"<hvoc>"*)
                hvoc=$(echo "$line" | sed -E 's/.*<hvoc>([^<]+)<\/hvoc>.*/\1/')
                # Insert data into MySQL database after parsing all fields for one record
                mysql -h "$DB_HOSTNAME" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --default-character-set=utf8mb4 -e \
                "INSERT INTO EmergencyHospitals (hpid, dutyName, dutyAddr, dutyTel3, wgs84Lat, wgs84Lon, availableBed, hvec, hvoc, lastUpdated) 
                VALUES ('$hpid', '$dutyName', '$dutyAddr', '$dutyTel3', '$wgs84Lat', '$wgs84Lon', '$availableBed', '$hvec', '$hvoc', NOW()) 
                ON DUPLICATE KEY UPDATE 
                dutyName=VALUES(dutyName), 
                dutyAddr=VALUES(dutyAddr), 
                dutyTel3=VALUES(dutyTel3), 
                wgs84Lat=VALUES(wgs84Lat), 
                wgs84Lon=VALUES(wgs84Lon), 
                availableBed=VALUES(availableBed), 
                hvec=VALUES(hvec), 
                hvoc=VALUES(hvoc), 
                lastUpdated=NOW();"
                ;;
        esac
    done
}

# Fetch emergency hospital data
fetch_and_insert_data "getEmrrmRltmUsefulSckbdInfoInqire"

echo "Data insertion complete."
