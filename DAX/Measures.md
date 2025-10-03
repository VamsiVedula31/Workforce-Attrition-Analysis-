DAX MEASURES

```Abesteeism_Rate_% =
DIVIDE(
    SUM('dd_project hr_data'[Absenteeism]),
    SUM('dd_project hr_data'[WorkDays])
)
______________________________________________________________________________

Headcount Based Attrition =
DIVIDE(
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        'dd_project hr_data'[Attrition] = "Yes"
    ),
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        USERELATIONSHIP('Date_Table'[Date],'dd_project hr_data'[HireDate_dt])
    )
)
______________________________________________________________________________

Pct_ChildCare_Benefit =
DIVIDE(
    COUNTROWS(
        (FILTER('dd_project hr_data', 'dd_project hr_data'[EmployeeBenefit_ChildCare] = 1))
        ),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_GymMembership_Benefit =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_HealthInsurance_Benefit =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_PaidLeave_Benefit =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[EmployeeBenefit_PaidLeave] =1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_Promoted_Employees =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[Promotion] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_RetirementPlan_Benefit =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[EmployeeBenefit_RetirementPlan] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)

______________________________________________________________________________

Pct_Satisfied_With_Compensation =
DIVIDE(
    COUNTROWS(FILTER('dd_project hr_data','dd_project hr_data'[JobSatisfaction_Compensation] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_Satisfied_With_JobSecurity =
DIVIDE(COUNTROWS(FILTER('dd_project hr_data', 'dd_project hr_data'[JobSatisfaction_JobSecurity]= 1)),
COUNTROWS('dd_project hr_data'),
0
)
______________________________________________________________________________

Pct_Satisfied_With_Management =
DIVIDE(COUNTROWS(FILTER('dd_project hr_data','dd_project hr_data'[JobSatisfaction_Management] = 1)),
COUNTROWS('dd_project hr_data'),
0
)
______________________________________________________________________________

Pct_Satisfied_With_PeerRelationship =
DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[JobSatisfaction_PeerRelationship] = 1)),
    COUNTROWS('dd_project hr_data'),
    0
)
______________________________________________________________________________

Pct_Satisfied_With_WorkLifeBalance =
 DIVIDE(
    COUNTROWS(
        FILTER('dd_project hr_data', 'dd_project hr_data'[JobSatisfaction_WorkLifeBalance] =1)),
    COUNTROWS('dd_project hr_data'),
    0
 )
______________________________________________________________________________

Rolling 12M Attrition Rate =
VAR Last_date = MAX ( Date_Table[Date] )
VAR First_date = EDATE( Last_date, -12 ) + 1
VAR TotalHeadCount12M =
    CALCULATE(
        DISTINCTCOUNT( 'dd_project hr_data'[Employee_ID] ),
        FILTER ( 'dd_project hr_data',
                'dd_project hr_data'[HireDate_dt] <= Last_date &&
                ( ISBLANK ( 'dd_project hr_data'[ExitDate_dt] ) || 'dd_project hr_data'[ExitDate_dt] >= First_date )
        )
    )
VAR Leavers12M =
    CALCULATE(
        DISTINCTCOUNT('dd_project hr_data'[Employee_ID] ),
        FILTER (
            'dd_project hr_data',
            'dd_project hr_data'[ExitDate_dt] >= First_date &&
            'dd_project hr_data'[ExitDate_dt] <= Last_date
        )
    )
RETURN
DIVIDE ( Leavers12M, TotalHeadCount12M )
______________________________________________________________________________

Total Employees (12M) =
CALCULATE(
    AVERAGEX(
        VALUES(Date_Table[Date]),
        COUNTROWS(
            FILTER(
                'dd_project hr_data',
                'dd_project hr_data'[HireDate_dt] <= Date_Table[Date]
                    && (ISBLANK('dd_project hr_data'[ExitDate_dt]) || 'dd_project hr_data'[ExitDate_dt] > Date_Table[Date])
            )
        )
    ),
    DATESINPERIOD(
        Date_Table[Date],
        MAX(Date_Table[Date]),
        -12,
        MONTH
    )
)```
______________________________________________________________________________

