EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:Zilog
LIBS:shardy
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Proto 1"
Date "2016-12-18"
Rev "a"
Comp "Easy80"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Z80CPU U6
U 1 1 584292FE
P 3050 2500
F 0 "U6" H 2500 3900 50  0000 L CNN
F 1 "Z80CPU" H 3300 3900 50  0000 L CNN
F 2 "Housings_DIP:DIP-40_W15.24mm" H 3050 2900 50  0001 C CNN
F 3 "" H 3050 2900 50  0000 C CNN
	1    3050 2500
	1    0    0    -1  
$EndComp
$Comp
L 27C64 U7
U 1 1 5842932F
P 6000 2200
F 0 "U7" H 5750 3200 50  0000 C CNN
F 1 "27C64" H 6000 1200 50  0000 C CNN
F 2 "Housings_DIP:DIP-28_W15.24mm" H 6000 2200 50  0001 C CNN
F 3 "" H 6000 2200 50  0000 C CNN
	1    6000 2200
	1    0    0    -1  
$EndComp
$Comp
L HM62256BLFP-7T U8
U 1 1 58429370
P 8900 2050
F 0 "U8" H 8600 2950 50  0000 C CNN
F 1 "HM62256BLFP-7T" H 9350 1250 50  0000 C CNN
F 2 "Housings_DIP:DIP-28_W15.24mm" H 8900 2050 50  0000 C CIN
F 3 "" H 8900 2050 50  0000 C CNN
	1    8900 2050
	1    0    0    -1  
$EndComp
$Comp
L 74LS244 U3
U 1 1 584293BC
P 7200 4300
F 0 "U3" H 7250 4100 50  0000 C CNN
F 1 "74LS244" H 7300 3900 50  0000 C CNN
F 2 "Housings_DIP:DIP-20_W7.62mm" H 7200 4300 50  0001 C CNN
F 3 "" H 7200 4300 50  0000 C CNN
	1    7200 4300
	1    0    0    -1  
$EndComp
$Comp
L 74LS374 U4
U 1 1 58429405
P 9650 4300
F 0 "U4" H 9650 4300 50  0000 C CNN
F 1 "74LS374" H 9700 3950 50  0000 C CNN
F 2 "Housings_DIP:DIP-20_W7.62mm" H 9650 4300 50  0001 C CNN
F 3 "" H 9650 4300 50  0000 C CNN
	1    9650 4300
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U5
U 1 1 58429452
P 2400 5850
F 0 "U5" H 2400 5950 50  0000 C CNN
F 1 "74LS139" H 2400 5750 50  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm" H 2400 5850 50  0001 C CNN
F 3 "" H 2400 5850 50  0000 C CNN
	1    2400 5850
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U5
U 2 1 584294B3
P 2400 4900
F 0 "U5" H 2400 5000 50  0000 C CNN
F 1 "74LS139" H 2400 4800 50  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm" H 2400 4900 50  0001 C CNN
F 3 "" H 2400 4900 50  0000 C CNN
	2    2400 4900
	1    0    0    -1  
$EndComp
$Comp
L 74LS04 U2
U 2 1 584295A4
P 1750 6700
F 0 "U2" H 1945 6815 50  0000 C CNN
F 1 "74LS04" H 1940 6575 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm" H 1750 6700 50  0001 C CNN
F 3 "" H 1750 6700 50  0000 C CNN
	2    1750 6700
	1    0    0    -1  
$EndComp
$Comp
L 74LS04 U2
U 3 1 584295CF
P 2900 6700
F 0 "U2" H 3095 6815 50  0000 C CNN
F 1 "74LS04" H 3090 6575 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm" H 2900 6700 50  0001 C CNN
F 3 "" H 2900 6700 50  0000 C CNN
	3    2900 6700
	1    0    0    -1  
$EndComp
$Comp
L 74LS04 U2
U 4 1 584295FE
P 4000 6700
F 0 "U2" H 4195 6815 50  0000 C CNN
F 1 "74LS04" H 4190 6575 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm" H 4000 6700 50  0001 C CNN
F 3 "" H 4000 6700 50  0000 C CNN
	4    4000 6700
	1    0    0    -1  
$EndComp
$Comp
L 74LS04 U2
U 1 1 58429629
P 8150 5100
F 0 "U2" H 8345 5215 50  0000 C CNN
F 1 "74LS04" H 8340 4975 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm" H 8150 5100 50  0001 C CNN
F 3 "" H 8150 5100 50  0000 C CNN
	1    8150 5100
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 58429899
P 1700 7100
F 0 "R5" V 1780 7100 50  0000 C CNN
F 1 "1200" V 1700 7100 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 1630 7100 50  0001 C CNN
F 3 "" H 1700 7100 50  0000 C CNN
	1    1700 7100
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 584298D6
P 2850 7100
F 0 "R4" V 2930 7100 50  0000 C CNN
F 1 "1200" V 2850 7100 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 2780 7100 50  0001 C CNN
F 3 "" H 2850 7100 50  0000 C CNN
	1    2850 7100
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 5842992F
P 4550 6950
F 0 "R3" V 4630 6950 50  0000 C CNN
F 1 "330" V 4550 6950 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 4480 6950 50  0001 C CNN
F 3 "" H 4550 6950 50  0000 C CNN
	1    4550 6950
	-1   0    0    1   
$EndComp
$Comp
L C C6
U 1 1 58429C00
P 1050 7000
F 0 "C6" H 1075 7100 50  0000 L CNN
F 1 "100pF" H 1075 6900 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1088 6850 50  0001 C CNN
F 3 "" H 1050 7000 50  0000 C CNN
	1    1050 7000
	-1   0    0    1   
$EndComp
$Comp
L CP1 C2
U 1 1 5842A0FF
P 6250 5950
F 0 "C2" H 6275 6050 50  0000 L CNN
F 1 "10uF" H 6275 5850 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 6250 5950 50  0001 C CNN
F 3 "" H 6250 5950 50  0000 C CNN
	1    6250 5950
	-1   0    0    -1  
$EndComp
$Comp
L CP1 C1
U 1 1 5842A162
P 5000 5950
F 0 "C1" H 5025 6050 50  0000 L CNN
F 1 "100uF" H 5025 5850 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5000 5950 50  0001 C CNN
F 3 "" H 5000 5950 50  0000 C CNN
	1    5000 5950
	-1   0    0    -1  
$EndComp
$Comp
L Crystal Y1
U 1 1 5842A306
P 2300 7450
F 0 "Y1" H 2300 7600 50  0000 C CNN
F 1 "4 MHz" H 2300 7300 50  0000 C CNN
F 2 "Crystals:Crystal_HC49-U_Vertical" H 2300 7450 50  0001 C CNN
F 3 "" H 2300 7450 50  0000 C CNN
	1    2300 7450
	1    0    0    -1  
$EndComp
Text GLabel 2150 3200 0    60   Input ~ 0
mreq
Text GLabel 1350 5150 0    60   Input ~ 0
mreq
NoConn ~ 2350 2300
NoConn ~ 2350 2400
NoConn ~ 2350 2600
NoConn ~ 2350 3700
Text GLabel 2150 3350 0    60   Input ~ 0
ioreq
Text GLabel 1350 6100 0    60   Input ~ 0
ioreq
Text GLabel 2150 3050 0    60   Input ~ 0
wr
Text GLabel 2150 2900 0    60   Input ~ 0
rd
Text GLabel 2150 1600 0    60   Input ~ 0
clock
$Comp
L VCC #PWR01
U 1 1 5842C5D8
P 1400 1750
F 0 "#PWR01" H 1400 1600 50  0001 C CNN
F 1 "VCC" H 1400 1900 50  0000 C CNN
F 2 "" H 1400 1750 50  0000 C CNN
F 3 "" H 1400 1750 50  0000 C CNN
	1    1400 1750
	1    0    0    -1  
$EndComp
Entry Wire Line
	3900 1300 4000 1400
Entry Wire Line
	3900 1400 4000 1500
Entry Wire Line
	3900 1500 4000 1600
Entry Wire Line
	3900 1600 4000 1700
Entry Wire Line
	3900 1700 4000 1800
Entry Wire Line
	3900 1800 4000 1900
Entry Wire Line
	3900 1900 4000 2000
Entry Wire Line
	3900 2000 4000 2100
Entry Wire Line
	3900 2100 4000 2200
Entry Wire Line
	3900 2200 4000 2300
Entry Wire Line
	3900 2300 4000 2400
Entry Wire Line
	3900 2400 4000 2500
Entry Wire Line
	3900 2500 4000 2600
Entry Wire Line
	3900 2600 4000 2700
Entry Wire Line
	3900 2700 4000 2800
Entry Wire Line
	3900 2800 4000 2900
Text Label 3750 1300 0    60   ~ 0
A0
Text Label 3750 1400 0    60   ~ 0
A1
Text Label 3750 1500 0    60   ~ 0
A2
Text Label 3750 1600 0    60   ~ 0
A3
Text Label 3750 1700 0    60   ~ 0
A4
Text Label 3750 1800 0    60   ~ 0
A5
Text Label 3750 1900 0    60   ~ 0
A6
Text Label 3750 2000 0    60   ~ 0
A7
Text Label 3750 2100 0    60   ~ 0
A8
Text Label 3750 2200 0    60   ~ 0
A9
Text Label 3750 2300 0    60   ~ 0
A10
Text Label 3750 2400 0    60   ~ 0
A11
Text Label 3750 2500 0    60   ~ 0
A12
Text Label 3750 2600 0    60   ~ 0
A13
Text Label 3750 2700 0    60   ~ 0
A14
Text Label 3750 2800 0    60   ~ 0
A15
Entry Wire Line
	5050 1200 5150 1300
Entry Wire Line
	5050 1300 5150 1400
Entry Wire Line
	5050 1400 5150 1500
Entry Wire Line
	5050 1500 5150 1600
Entry Wire Line
	5050 1600 5150 1700
Entry Wire Line
	5050 1700 5150 1800
Entry Wire Line
	5050 1800 5150 1900
Entry Wire Line
	5050 1900 5150 2000
Entry Wire Line
	5050 2000 5150 2100
Entry Wire Line
	5050 2100 5150 2200
Entry Wire Line
	5050 2200 5150 2300
Entry Wire Line
	5050 2300 5150 2400
Entry Wire Line
	5050 2400 5150 2500
Text Label 5450 1050 0    60   ~ 0
AdressBus
Entry Wire Line
	8150 1200 8250 1300
Entry Wire Line
	8150 1300 8250 1400
Entry Wire Line
	8150 1400 8250 1500
Entry Wire Line
	8150 1500 8250 1600
Entry Wire Line
	8150 1600 8250 1700
Entry Wire Line
	8150 1700 8250 1800
Entry Wire Line
	8150 1800 8250 1900
Entry Wire Line
	8150 1900 8250 2000
Entry Wire Line
	8150 2000 8250 2100
Entry Wire Line
	8150 2100 8250 2200
Entry Wire Line
	8150 2200 8250 2300
Entry Wire Line
	8150 2300 8250 2400
Entry Wire Line
	8150 2400 8250 2500
Entry Wire Line
	8150 2500 8250 2600
Entry Wire Line
	8150 2600 8250 2700
Text Label 8250 1300 0    60   ~ 0
A0
Text Label 8250 1400 0    60   ~ 0
A1
Text Label 8250 1500 0    60   ~ 0
A2
Text Label 8250 1600 0    60   ~ 0
A3
Text Label 8250 1700 0    60   ~ 0
A4
Text Label 8250 1800 0    60   ~ 0
A5
Text Label 8250 1900 0    60   ~ 0
A6
Text Label 8250 2000 0    60   ~ 0
A7
Text Label 8250 2100 0    60   ~ 0
A8
Text Label 8250 2200 0    60   ~ 0
A9
Text Label 8250 2300 0    60   ~ 0
A10
Text Label 8250 2400 0    60   ~ 0
A11
Text Label 8250 2500 0    60   ~ 0
A12
Text Label 8250 2600 0    60   ~ 0
A13
Text Label 8250 2700 0    60   ~ 0
A14
Entry Wire Line
	6850 1300 6950 1400
Entry Wire Line
	6850 1400 6950 1500
Entry Wire Line
	6850 1500 6950 1600
Entry Wire Line
	6850 1600 6950 1700
Entry Wire Line
	6850 1700 6950 1800
Entry Wire Line
	6850 1800 6950 1900
Entry Wire Line
	6850 1900 6950 2000
Entry Wire Line
	6850 2000 6950 2100
Entry Wire Line
	9550 1300 9650 1400
Entry Wire Line
	9550 1400 9650 1500
Entry Wire Line
	9550 1500 9650 1600
Entry Wire Line
	9550 1600 9650 1700
Entry Wire Line
	9550 1700 9650 1800
Entry Wire Line
	9550 1800 9650 1900
Entry Wire Line
	9550 1900 9650 2000
Entry Wire Line
	9550 2000 9650 2100
Entry Wire Line
	3900 3000 4000 3100
Entry Wire Line
	3900 3100 4000 3200
Entry Wire Line
	3900 3200 4000 3300
Entry Wire Line
	3900 3300 4000 3400
Entry Wire Line
	3900 3400 4000 3500
Entry Wire Line
	3900 3500 4000 3600
Entry Wire Line
	3900 3600 4000 3700
Entry Wire Line
	3900 3700 4000 3800
Text Label 9400 1300 0    60   ~ 0
D0
Text Label 9400 1400 0    60   ~ 0
D1
Text Label 9400 1500 0    60   ~ 0
D2
Text Label 9400 1600 0    60   ~ 0
D3
Text Label 9400 1700 0    60   ~ 0
D4
Text Label 9400 1800 0    60   ~ 0
D5
Text Label 9400 1900 0    60   ~ 0
D6
Text Label 9400 2000 0    60   ~ 0
D7
Text Label 9400 2150 0    60   ~ 0
D8
Text Label 6700 1300 0    60   ~ 0
D0
Text Label 6700 1400 0    60   ~ 0
D1
Text Label 6700 1500 0    60   ~ 0
D2
Text Label 6700 1600 0    60   ~ 0
D3
Text Label 6700 1700 0    60   ~ 0
D4
Text Label 6700 1800 0    60   ~ 0
D5
Text Label 6700 1900 0    60   ~ 0
D6
Text Label 6700 2000 0    60   ~ 0
D7
Text Label 3750 3000 0    60   ~ 0
D0
Text Label 3750 3100 0    60   ~ 0
D1
Text Label 3750 3200 0    60   ~ 0
D2
Text Label 3750 3300 0    60   ~ 0
D3
Text Label 3750 3400 0    60   ~ 0
D4
Text Label 3750 3500 0    60   ~ 0
D5
Text Label 3750 3600 0    60   ~ 0
D6
Text Label 3750 3700 0    60   ~ 0
D7
Entry Wire Line
	8700 3700 8800 3800
Entry Wire Line
	8700 3800 8800 3900
Entry Wire Line
	8700 3900 8800 4000
Entry Wire Line
	8700 4000 8800 4100
Entry Wire Line
	8700 4100 8800 4200
Entry Wire Line
	8700 4200 8800 4300
Entry Wire Line
	8700 4300 8800 4400
Entry Wire Line
	8700 4400 8800 4500
Entry Wire Line
	8050 3800 8150 3900
Entry Wire Line
	8050 3900 8150 4000
Entry Wire Line
	8050 4000 8150 4100
Entry Wire Line
	8050 4100 8150 4200
Entry Wire Line
	8050 4200 8150 4300
Entry Wire Line
	8050 4300 8150 4400
Entry Wire Line
	8050 4400 8150 4500
Entry Wire Line
	8050 4500 8150 4600
Text Label 7900 3800 0    60   ~ 0
D0
Text Label 7900 3900 0    60   ~ 0
D2
Text Label 7900 4000 0    60   ~ 0
D4
Text Label 7900 4100 0    60   ~ 0
D6
Text Label 7900 4200 0    60   ~ 0
D7
Text Label 7900 4300 0    60   ~ 0
D5
Text Label 7900 4400 0    60   ~ 0
D3
Text Label 7900 4500 0    60   ~ 0
D1
Text Label 8800 3800 0    60   ~ 0
D0
Text Label 8800 3900 0    60   ~ 0
D2
Text Label 8800 4000 0    60   ~ 0
D4
Text Label 8800 4100 0    60   ~ 0
D6
Text Label 8800 4200 0    60   ~ 0
D7
Text Label 8800 4300 0    60   ~ 0
D5
Text Label 8800 4400 0    60   ~ 0
D3
Text Label 8800 4500 0    60   ~ 0
D1
$Comp
L GND #PWR02
U 1 1 58432E5B
P 8800 4900
F 0 "#PWR02" H 8800 4650 50  0001 C CNN
F 1 "GND" H 8800 4750 50  0000 C CNN
F 2 "" H 8800 4900 50  0000 C CNN
F 3 "" H 8800 4900 50  0000 C CNN
	1    8800 4900
	1    0    0    -1  
$EndComp
Text GLabel 7700 5100 0    60   Input ~ 0
outcs
Text GLabel 6250 5050 0    60   Input ~ 0
incs
NoConn ~ 3250 5000
NoConn ~ 3250 5200
Text GLabel 3400 4800 2    60   Input ~ 0
ramcs
Text GLabel 3400 4600 2    60   Input ~ 0
romcs
$Comp
L GND #PWR03
U 1 1 58434523
P 1400 4600
F 0 "#PWR03" H 1400 4350 50  0001 C CNN
F 1 "GND" H 1400 4450 50  0000 C CNN
F 2 "" H 1400 4600 50  0000 C CNN
F 3 "" H 1400 4600 50  0000 C CNN
	1    1400 4600
	1    0    0    1   
$EndComp
Text GLabel 1350 5750 0    60   Input ~ 0
wr
NoConn ~ 3250 5550
NoConn ~ 3250 5750
Text GLabel 3400 5950 2    60   Input ~ 0
outcs
Text GLabel 3400 6150 2    60   Input ~ 0
incs
$Comp
L GND #PWR04
U 1 1 58434EE3
P 3050 4100
F 0 "#PWR04" H 3050 3850 50  0001 C CNN
F 1 "GND" H 3050 3950 50  0000 C CNN
F 2 "" H 3050 4100 50  0000 C CNN
F 3 "" H 3050 4100 50  0000 C CNN
	1    3050 4100
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR05
U 1 1 584351C5
P 3050 900
F 0 "#PWR05" H 3050 750 50  0001 C CNN
F 1 "VCC" H 3050 1050 50  0000 C CNN
F 2 "" H 3050 900 50  0000 C CNN
F 3 "" H 3050 900 50  0000 C CNN
	1    3050 900 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 584368FD
P 650 1250
F 0 "#PWR06" H 650 1000 50  0001 C CNN
F 1 "GND" H 650 1100 50  0000 C CNN
F 2 "" H 650 1250 50  0000 C CNN
F 3 "" H 650 1250 50  0000 C CNN
	1    650  1250
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 58436D15
P 1050 7300
F 0 "#PWR07" H 1050 7050 50  0001 C CNN
F 1 "GND" H 1050 7150 50  0000 C CNN
F 2 "" H 1050 7300 50  0000 C CNN
F 3 "" H 1050 7300 50  0000 C CNN
	1    1050 7300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR08
U 1 1 58437C5E
P 4550 7200
F 0 "#PWR08" H 4550 7050 50  0001 C CNN
F 1 "VCC" H 4550 7350 50  0000 C CNN
F 2 "" H 4550 7200 50  0000 C CNN
F 3 "" H 4550 7200 50  0000 C CNN
	1    4550 7200
	-1   0    0    1   
$EndComp
Text GLabel 4700 6700 2    60   Input ~ 0
clock
$Comp
L Battery BT1
U 1 1 58439C50
P 4500 5950
F 0 "BT1" H 4600 6000 50  0000 L CNN
F 1 "Battery" H 4600 5900 50  0000 L CNN
F 2 "Connect:JACK_ALIM" V 4500 5990 50  0001 C CNN
F 3 "" V 4500 5990 50  0000 C CNN
	1    4500 5950
	-1   0    0    -1  
$EndComp
$Comp
L CONN_01X10 J2
U 1 1 5843A3C6
P 5850 4150
F 0 "J2" H 5850 4700 50  0000 C CNN
F 1 "CONN_01X10" V 5950 4150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x10" H 5850 4150 50  0001 C CNN
F 3 "" H 5850 4150 50  0000 C CNN
	1    5850 4150
	-1   0    0    -1  
$EndComp
$Comp
L VCC #PWR09
U 1 1 5843A5CB
P 6200 3650
F 0 "#PWR09" H 6200 3500 50  0001 C CNN
F 1 "VCC" H 6200 3800 50  0000 C CNN
F 2 "" H 6200 3650 50  0000 C CNN
F 3 "" H 6200 3650 50  0000 C CNN
	1    6200 3650
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR010
U 1 1 5843A61F
P 6200 4700
F 0 "#PWR010" H 6200 4450 50  0001 C CNN
F 1 "GND" H 6200 4550 50  0000 C CNN
F 2 "" H 6200 4700 50  0000 C CNN
F 3 "" H 6200 4700 50  0000 C CNN
	1    6200 4700
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X10 J1
U 1 1 5843B2FB
P 10950 4150
F 0 "J1" H 10950 4700 50  0000 C CNN
F 1 "CONN_01X10" V 11050 4150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x10" H 10950 4150 50  0001 C CNN
F 3 "" H 10950 4150 50  0000 C CNN
	1    10950 4150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR011
U 1 1 5843B68D
P 10600 3550
F 0 "#PWR011" H 10600 3400 50  0001 C CNN
F 1 "VCC" H 10600 3700 50  0000 C CNN
F 2 "" H 10600 3550 50  0000 C CNN
F 3 "" H 10600 3550 50  0000 C CNN
	1    10600 3550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR012
U 1 1 5843B6E3
P 10600 4750
F 0 "#PWR012" H 10600 4500 50  0001 C CNN
F 1 "GND" H 10600 4600 50  0000 C CNN
F 2 "" H 10600 4750 50  0000 C CNN
F 3 "" H 10600 4750 50  0000 C CNN
	1    10600 4750
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR013
U 1 1 5843CE0B
P 6850 5600
F 0 "#PWR013" H 6850 5450 50  0001 C CNN
F 1 "VCC" H 6850 5750 50  0000 C CNN
F 2 "" H 6850 5600 50  0000 C CNN
F 3 "" H 6850 5600 50  0000 C CNN
	1    6850 5600
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR014
U 1 1 5843E806
P 5600 6350
F 0 "#PWR014" H 5600 6100 50  0001 C CNN
F 1 "GND" H 5600 6200 50  0000 C CNN
F 2 "" H 5600 6350 50  0000 C CNN
F 3 "" H 5600 6350 50  0000 C CNN
	1    5600 6350
	-1   0    0    -1  
$EndComp
Text GLabel 5150 3000 0    60   Input ~ 0
romcs
Text GLabel 5150 3150 0    60   Input ~ 0
rd
$Comp
L VCC #PWR015
U 1 1 58441202
P 4900 2650
F 0 "#PWR015" H 4900 2500 50  0001 C CNN
F 1 "VCC" H 4900 2800 50  0000 C CNN
F 2 "" H 4900 2650 50  0000 C CNN
F 3 "" H 4900 2650 50  0000 C CNN
	1    4900 2650
	1    0    0    -1  
$EndComp
NoConn ~ 5300 2600
Text Label 5150 1300 0    60   ~ 0
A0
Text Label 5150 1400 0    60   ~ 0
A1
Text Label 5150 1500 0    60   ~ 0
A2
Text Label 5150 1600 0    60   ~ 0
A3
Text Label 5150 1700 0    60   ~ 0
A4
Text Label 5150 1800 0    60   ~ 0
A5
Text Label 5150 1900 0    60   ~ 0
A6
Text Label 5150 2000 0    60   ~ 0
A7
Text Label 5150 2100 0    60   ~ 0
A8
Text Label 5150 2200 0    60   ~ 0
A9
Text Label 5150 2300 0    60   ~ 0
A10
Text Label 5150 2400 0    60   ~ 0
A11
Text Label 5150 2500 0    60   ~ 0
A12
Text GLabel 9750 2400 2    60   Input ~ 0
ramcs
Text GLabel 9750 2250 2    60   Input ~ 0
wr
Text GLabel 9750 2100 2    60   Input ~ 0
rd
Entry Wire Line
	850  4700 950  4800
Entry Wire Line
	850  5500 950  5600
Text Label 1000 4800 0    60   ~ 0
A15
Text Label 1000 5600 0    60   ~ 0
A0
$Comp
L LM7805CT U1
U 1 1 58461051
P 5600 5750
F 0 "U1" H 5400 5950 50  0000 C CNN
F 1 "LM7805CT" H 5600 5950 50  0000 L CNN
F 2 "TO_SOT_Packages_THT:TO-220_Neutral123_Horizontal" H 5600 5850 50  0000 C CIN
F 3 "" H 5600 5750 50  0000 C CNN
	1    5600 5750
	1    0    0    -1  
$EndComp
Text GLabel 6500 3800 0    60   Input ~ 0
in0
Text GLabel 6500 3900 0    60   Input ~ 0
in2
Text GLabel 6500 4000 0    60   Input ~ 0
in4
Text GLabel 6500 4100 0    60   Input ~ 0
in6
Text GLabel 6500 4200 0    60   Input ~ 0
in7
Text GLabel 6500 4300 0    60   Input ~ 0
in5
Text GLabel 6500 4400 0    60   Input ~ 0
in3
Text GLabel 6500 4500 0    60   Input ~ 0
in1
Text GLabel 6050 3800 2    60   Input ~ 0
in0
Text GLabel 6050 3900 2    60   Input ~ 0
in1
Text GLabel 6050 4000 2    60   Input ~ 0
in2
Text GLabel 6050 4100 2    60   Input ~ 0
in3
Text GLabel 6050 4200 2    60   Input ~ 0
in4
Text GLabel 6050 4300 2    60   Input ~ 0
in5
Text GLabel 6050 4400 2    60   Input ~ 0
in6
Text GLabel 6050 4500 2    60   Input ~ 0
in7
Text GLabel 10750 3800 0    60   Input ~ 0
o0
Text GLabel 10750 3900 0    60   Input ~ 0
o1
Text GLabel 10750 4000 0    60   Input ~ 0
o2
Text GLabel 10750 4100 0    60   Input ~ 0
o3
Text GLabel 10750 4200 0    60   Input ~ 0
o4
Text GLabel 10750 4300 0    60   Input ~ 0
o5
Text GLabel 10750 4400 0    60   Input ~ 0
o6
Text GLabel 10750 4500 0    60   Input ~ 0
o7
Text GLabel 10350 3800 2    60   Input ~ 0
o0
Text GLabel 10350 3900 2    60   Input ~ 0
o2
Text GLabel 10350 4000 2    60   Input ~ 0
o4
Text GLabel 10350 4100 2    60   Input ~ 0
o6
Text GLabel 10350 4200 2    60   Input ~ 0
o7
Text GLabel 10350 4300 2    60   Input ~ 0
o5
Text GLabel 10350 4400 2    60   Input ~ 0
o3
Text GLabel 10350 4500 2    60   Input ~ 0
o1
$Comp
L LED D1
U 1 1 5852DA4A
P 6600 5900
F 0 "D1" H 6600 6000 50  0000 C CNN
F 1 "LED" H 6600 5800 50  0000 C CNN
F 2 "LEDs:LED-5MM" H 6600 5900 50  0001 C CNN
F 3 "" H 6600 5900 50  0000 C CNN
	1    6600 5900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2350 3200 2150 3200
Wire Wire Line
	1350 5150 1550 5150
Wire Wire Line
	2150 3350 2250 3350
Wire Wire Line
	2250 3350 2250 3300
Wire Wire Line
	2250 3300 2350 3300
Wire Wire Line
	1350 6100 1550 6100
Wire Wire Line
	2350 3100 2250 3100
Wire Wire Line
	2250 3100 2250 3050
Wire Wire Line
	2250 3050 2150 3050
Wire Wire Line
	2150 2900 2250 2900
Wire Wire Line
	2250 2900 2250 3000
Wire Wire Line
	2250 3000 2350 3000
Wire Wire Line
	2350 1600 2150 1600
Wire Wire Line
	1400 1900 2350 1900
Wire Wire Line
	1400 1750 1400 3600
Wire Wire Line
	2350 2000 2150 2000
Wire Wire Line
	2150 1900 2150 2500
Connection ~ 2150 1900
Wire Wire Line
	2150 2500 2350 2500
Connection ~ 2150 2000
Wire Wire Line
	1400 3600 2350 3600
Connection ~ 1400 1900
Wire Wire Line
	3750 1300 3900 1300
Wire Wire Line
	3900 1400 3750 1400
Wire Wire Line
	3750 1500 3900 1500
Wire Wire Line
	3900 1600 3750 1600
Wire Wire Line
	3750 1700 3900 1700
Wire Wire Line
	3900 1800 3750 1800
Wire Wire Line
	3750 1900 3900 1900
Wire Wire Line
	3750 2000 3900 2000
Wire Wire Line
	3900 2100 3750 2100
Wire Wire Line
	3750 2200 3900 2200
Wire Wire Line
	3900 2300 3750 2300
Wire Wire Line
	3750 2400 3900 2400
Wire Wire Line
	3900 2500 3750 2500
Wire Wire Line
	3750 2600 3900 2600
Wire Wire Line
	3900 2700 3750 2700
Wire Wire Line
	3750 2800 3900 2800
Wire Wire Line
	5150 1300 5300 1300
Wire Wire Line
	5150 1400 5300 1400
Wire Wire Line
	5150 1500 5300 1500
Wire Wire Line
	5150 1600 5300 1600
Wire Wire Line
	5150 1700 5300 1700
Wire Wire Line
	5150 1800 5300 1800
Wire Wire Line
	5150 1900 5300 1900
Wire Wire Line
	5150 2000 5300 2000
Wire Wire Line
	5150 2100 5300 2100
Wire Wire Line
	5150 2200 5300 2200
Wire Wire Line
	5150 2300 5300 2300
Wire Wire Line
	5150 2400 5300 2400
Wire Wire Line
	5150 2500 5300 2500
Wire Bus Line
	5050 1100 5050 2400
Wire Bus Line
	4000 1100 4000 2900
Wire Wire Line
	8250 1300 8400 1300
Wire Wire Line
	8400 1400 8250 1400
Wire Wire Line
	8400 1500 8250 1500
Wire Wire Line
	8250 1600 8400 1600
Wire Wire Line
	8400 1700 8250 1700
Wire Wire Line
	8250 1800 8400 1800
Wire Wire Line
	8400 1900 8250 1900
Wire Wire Line
	8250 2000 8400 2000
Wire Wire Line
	8400 2100 8250 2100
Wire Wire Line
	8250 2200 8400 2200
Wire Wire Line
	8400 2300 8250 2300
Wire Wire Line
	8250 2400 8400 2400
Wire Wire Line
	8400 2500 8250 2500
Wire Wire Line
	8250 2600 8400 2600
Wire Wire Line
	8400 2700 8250 2700
Wire Bus Line
	8150 1100 8150 2600
Wire Wire Line
	3900 3000 3750 3000
Wire Wire Line
	3900 3100 3750 3100
Wire Wire Line
	3750 3200 3900 3200
Wire Wire Line
	3900 3300 3750 3300
Wire Wire Line
	3750 3400 3900 3400
Wire Wire Line
	3900 3500 3750 3500
Wire Wire Line
	3750 3600 3900 3600
Wire Wire Line
	3900 3700 3750 3700
Wire Wire Line
	6700 1300 6850 1300
Wire Wire Line
	6850 1400 6700 1400
Wire Wire Line
	6700 1500 6850 1500
Wire Wire Line
	6850 1600 6700 1600
Wire Wire Line
	6700 1700 6850 1700
Wire Wire Line
	6850 1800 6700 1800
Wire Wire Line
	6700 1900 6850 1900
Wire Wire Line
	6850 2000 6700 2000
Wire Wire Line
	9400 2000 9550 2000
Wire Wire Line
	9550 1900 9400 1900
Wire Wire Line
	9400 1800 9550 1800
Wire Wire Line
	9550 1700 9400 1700
Wire Wire Line
	9400 1600 9550 1600
Wire Wire Line
	9400 1500 9550 1500
Wire Wire Line
	9550 1400 9400 1400
Wire Wire Line
	9400 1300 9550 1300
Wire Bus Line
	9650 1400 9650 3450
Wire Bus Line
	9650 3450 4000 3450
Wire Bus Line
	6950 1400 6950 3450
Wire Bus Line
	4000 3100 4000 4400
Wire Wire Line
	7900 3800 8050 3800
Wire Wire Line
	8050 3900 7900 3900
Wire Wire Line
	7900 4000 8050 4000
Wire Wire Line
	8050 4100 7900 4100
Wire Wire Line
	7900 4200 8050 4200
Wire Wire Line
	8050 4300 7900 4300
Wire Wire Line
	7900 4400 8050 4400
Wire Wire Line
	8050 4500 7900 4500
Wire Wire Line
	8800 3800 8950 3800
Wire Wire Line
	8950 3900 8800 3900
Wire Wire Line
	8800 4000 8950 4000
Wire Wire Line
	8950 4100 8800 4100
Wire Wire Line
	8800 4200 8950 4200
Wire Wire Line
	8950 4300 8800 4300
Wire Wire Line
	8800 4400 8950 4400
Wire Wire Line
	8950 4500 8800 4500
Wire Bus Line
	8700 3450 8700 4400
Wire Bus Line
	8150 3450 8150 4600
Wire Wire Line
	8950 4800 8800 4800
Wire Wire Line
	8800 4800 8800 4900
Wire Wire Line
	8950 4700 8600 4700
Wire Wire Line
	8600 4700 8600 5100
Wire Wire Line
	6450 4700 6500 4700
Wire Wire Line
	6500 4800 6450 4800
Wire Wire Line
	6450 4700 6450 5050
Wire Wire Line
	3400 4600 3250 4600
Wire Wire Line
	1550 4650 1400 4650
Wire Wire Line
	1400 4650 1400 4600
Wire Wire Line
	3250 5950 3400 5950
Wire Wire Line
	3400 6150 3250 6150
Wire Wire Line
	3050 4000 3050 4100
Wire Wire Line
	3050 900  3050 1000
Wire Wire Line
	1050 7150 1050 7300
Wire Wire Line
	1050 6700 1300 6700
Wire Wire Line
	1050 6700 1050 6850
Wire Wire Line
	1250 6700 1250 7450
Wire Wire Line
	1250 7100 1550 7100
Connection ~ 1250 6700
Wire Wire Line
	2200 6700 2450 6700
Wire Wire Line
	2300 6700 2300 7100
Wire Wire Line
	1850 7100 2700 7100
Connection ~ 2300 6700
Connection ~ 2300 7100
Wire Wire Line
	1250 7450 2150 7450
Connection ~ 1250 7100
Wire Wire Line
	3350 6700 3550 6700
Wire Wire Line
	3450 6700 3450 7450
Wire Wire Line
	3450 7100 3000 7100
Connection ~ 3450 6700
Wire Wire Line
	3450 7450 2450 7450
Connection ~ 3450 7100
Wire Wire Line
	4450 6700 4700 6700
Wire Wire Line
	4550 6700 4550 6800
Wire Wire Line
	4550 7100 4550 7200
Connection ~ 4550 6700
Wire Wire Line
	6200 3650 6200 3700
Wire Wire Line
	6200 3700 6050 3700
Wire Wire Line
	6050 4600 6200 4600
Wire Wire Line
	6200 4600 6200 4700
Wire Wire Line
	10750 4600 10600 4600
Wire Wire Line
	10600 4600 10600 4750
Wire Wire Line
	10600 3550 10600 3700
Wire Wire Line
	10600 3700 10750 3700
Wire Wire Line
	6850 5700 6850 5600
Connection ~ 6250 5700
Wire Wire Line
	6250 5800 6250 5700
Wire Wire Line
	5600 6000 5600 6350
Wire Wire Line
	6250 6200 6250 6100
Wire Wire Line
	4500 5700 5200 5700
Wire Wire Line
	5000 5700 5000 5800
Wire Wire Line
	5000 6200 5000 6100
Connection ~ 5600 6200
Wire Wire Line
	4500 5700 4500 5800
Connection ~ 5000 5700
Wire Wire Line
	4500 6200 4500 6100
Connection ~ 5000 6200
Wire Wire Line
	4900 2700 5300 2700
Wire Wire Line
	4900 2700 4900 2650
Wire Wire Line
	5300 2800 5150 2800
Wire Wire Line
	5150 2800 5150 2700
Connection ~ 5150 2700
Wire Wire Line
	5150 3000 5300 3000
Wire Wire Line
	5300 3100 5250 3100
Wire Wire Line
	5250 3100 5250 3150
Wire Wire Line
	5250 3150 5150 3150
Wire Wire Line
	9400 2250 9750 2250
Wire Wire Line
	9400 2400 9750 2400
Wire Bus Line
	4000 4400 850  4400
Wire Wire Line
	1350 5750 1550 5750
Wire Wire Line
	1550 5600 950  5600
Wire Wire Line
	950  4800 1550 4800
Wire Bus Line
	850  4400 850  5500
Wire Wire Line
	9400 2150 9700 2150
Wire Wire Line
	9700 2150 9700 2100
Wire Wire Line
	9700 2100 9750 2100
Wire Wire Line
	6450 5050 6250 5050
Connection ~ 6450 4800
Wire Wire Line
	6000 5700 6850 5700
Wire Wire Line
	4500 6200 6250 6200
$Comp
L R R1
U 1 1 5852E3AF
P 6600 6350
F 0 "R1" V 6680 6350 50  0000 C CNN
F 1 "330" V 6600 6350 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 6530 6350 50  0001 C CNN
F 3 "" H 6600 6350 50  0000 C CNN
	1    6600 6350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR016
U 1 1 5852E40E
P 6600 6600
F 0 "#PWR016" H 6600 6350 50  0001 C CNN
F 1 "GND" H 6600 6450 50  0000 C CNN
F 2 "" H 6600 6600 50  0000 C CNN
F 3 "" H 6600 6600 50  0000 C CNN
	1    6600 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	6600 6100 6600 6200
Wire Wire Line
	6600 6500 6600 6600
Connection ~ 6600 5700
Wire Wire Line
	3250 4800 3400 4800
Wire Bus Line
	4000 1100 8150 1100
Wire Wire Line
	2100 1300 2350 1300
Wire Wire Line
	2100 850  2100 1300
Wire Wire Line
	650  1100 650  1250
$Comp
L R R6
U 1 1 58534470
P 1450 1100
F 0 "R6" V 1530 1100 50  0000 C CNN
F 1 "10K" V 1450 1100 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 1380 1100 50  0001 C CNN
F 3 "" H 1450 1100 50  0000 C CNN
	1    1450 1100
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 585344E7
P 1450 850
F 0 "R2" V 1530 850 50  0000 C CNN
F 1 "10K" V 1450 850 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM7mm" V 1380 850 50  0001 C CNN
F 3 "" H 1450 850 50  0000 C CNN
	1    1450 850 
	0    1    1    0   
$EndComp
$Comp
L CP1 C3
U 1 1 585349CE
P 1700 1350
F 0 "C3" H 1725 1450 50  0000 L CNN
F 1 "10uF" H 1725 1250 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1700 1350 50  0001 C CNN
F 3 "" H 1700 1350 50  0000 C CNN
	1    1700 1350
	-1   0    0    -1  
$EndComp
$Comp
L SW_PUSH SW1
U 1 1 58534C72
P 950 1100
F 0 "SW1" H 1100 1210 50  0000 C CNN
F 1 "SW_PUSH" H 950 1020 50  0000 C CNN
F 2 "Buttons_Switches_ThroughHole:SW_PUSH_6mm" H 950 1100 50  0001 C CNN
F 3 "" H 950 1100 50  0000 C CNN
	1    950  1100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR017
U 1 1 58534DAF
P 1700 1550
F 0 "#PWR017" H 1700 1300 50  0001 C CNN
F 1 "GND" H 1700 1400 50  0000 C CNN
F 2 "" H 1700 1550 50  0000 C CNN
F 3 "" H 1700 1550 50  0000 C CNN
	1    1700 1550
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR018
U 1 1 58534DF4
P 1000 800
F 0 "#PWR018" H 1000 650 50  0001 C CNN
F 1 "VCC" H 1000 950 50  0000 C CNN
F 2 "" H 1000 800 50  0000 C CNN
F 3 "" H 1000 800 50  0000 C CNN
	1    1000 800 
	1    0    0    -1  
$EndComp
Wire Wire Line
	1000 800  1000 850 
Wire Wire Line
	1000 850  1300 850 
Wire Wire Line
	1250 1100 1300 1100
Wire Wire Line
	1600 850  2100 850 
Wire Wire Line
	1600 1100 2100 1100
Connection ~ 2100 1100
Wire Wire Line
	1700 1200 1700 1100
Connection ~ 1700 1100
Wire Wire Line
	1700 1550 1700 1500
$EndSCHEMATC
