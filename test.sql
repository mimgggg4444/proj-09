CREATE DATABASE IF NOT EXISTS `emergency_db`;
use `emergency_db`;


CREATE TABLE EmergencyHospitals (
    hpid VARCHAR(20) PRIMARY KEY,
    dutyName VARCHAR(100),
    dutyAddr VARCHAR(200),
    dutyTel3 VARCHAR(20),
    wgs84Lat DECIMAL(10, 8),
    wgs84Lon DECIMAL(11, 8),
    availableBed INT,
    hvec VARCHAR(10),
    hvoc VARCHAR(10),
    lastUpdated TIMESTAMP
);

/*
위의 데이터는 
https://www.data.go.kr/data/15000563/openapi.do
위 사이트의 api데이터를 기반으로 스키마 생성하는 로직입니다.


data베이스 생성 및 use 문 추가 안됨


*/
