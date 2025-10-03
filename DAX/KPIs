KEY PERFORMANCE INDICATORS (KPIs)

KPI - Attrition Rate - Low Training =

VAR Threshold = 20
VAR StartDate = EDATE(TODAY(), -12)
RETURN
DIVIDE(
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        'dd_project hr_data'[Training_Hours] < Threshold,
        'dd_project hr_data'[Attrition] = "Yes",
        'dd_project hr_data'[ExitDate_dt] >= StartDate,
        'dd_project hr_data'[ExitDate_dt] <= TODAY()
    ),
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        'dd_project hr_data'[Training_Hours] < Threshold,
        'dd_project hr_data'[HireDate_dt]<= TODAY()   -- only include employees who were active in this 12M
    ),
    0
)
______________________________________________________________________________

KPI - Average Training Hours =
AVERAGE('dd_project hr_data'[Training_Hours])
______________________________________________________________________________

KPI - Avg Tenure-Leavers =
CALCULATE(
    AVERAGE('dd_project hr_data'[Years_of_Service]),
    'dd_project hr_data'[Attrition] = "Yes"
)
______________________________________________________________________________

KPI - Avg.Engagement_BenefitHolders =
CALCULATE (
    AVERAGE ( 'dd_project hr_data'[Employee_Engagement_Score] ),
    FILTER (
        'dd_project hr_data',
        'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 1
            || 'dd_project hr_data'[EmployeeBenefit_PaidLeave] = 1
            || 'dd_project hr_data'[EmployeeBenefit_ChildCare] = 1
            || 'dd_project hr_data'[EmployeeBenefit_RetirementPlan] = 1
            || 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 1
    )
)
______________________________________________________________________________

KPI - Engagement Gap =
VAR WithBenefits =
    CALCULATE(
        AVERAGE('dd_project hr_data'[Employee_Engagement_Score]),
        FILTER(
            'dd_project hr_data',
            'dd_project hr_data'[EmployeeBenefit_ChildCare] = 1
            || 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 1
            || 'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 1
            || 'dd_project hr_data'[EmployeeBenefit_PaidLeave] = 1
            || 'dd_project hr_data'[Promotion] = 1
        )
    )
VAR NoBenefits =
    CALCULATE(
        AVERAGE('dd_project hr_data'[Employee_Engagement_Score]),
        FILTER(
            'dd_project hr_data',
            'dd_project hr_data'[EmployeeBenefit_ChildCare] = 0
            && 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 0
            && 'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 0
            && 'dd_project hr_data'[EmployeeBenefit_PaidLeave] = 0
            && 'dd_project hr_data'[Promotion] = 0
        )
    )
RETURN
WithBenefits - NoBenefits
______________________________________________________________________________

KPI - Engagement Lift =
VAR HighEng=
    CALCULATE( AVERAGE( 'dd_project hr_data'[Employee_Engagement_Score]),
                'dd_project hr_data'[Training_Hours] >= 20 )
VAR LowEng =
    CALCULATE( AVERAGE('dd_project hr_data'[Employee_Engagement_Score] ),
                'dd_project hr_data'[Training_Hours] < 20 )
RETURN
HighEng - LowEng
// Difference between High and Low Training Groups
______________________________________________________________________________

KPI - High Engagement % =
DIVIDE(
    CALCULATE(
        COUNTROWS('dd_project hr_data'), 'dd_project hr_data'[Employee_Engagement_Score] >= 4),
        COUNTROWS('dd_project hr_data')
)
______________________________________________________________________________

KPI - Low Driver % =
VAR Drivers =
    UNION(
        ROW("Driver", "Management",         "Value",        [Pct_Satisfied_With_Management]),
        ROW("Driver", "Job Security",       "Value",        [Pct_Satisfied_With_JobSecurity]),
        ROW("Driver", "Compensation",       "Value",        [Pct_Satisfied_With_Compensation]),
        ROW("Driver", "Work-Life Balance",  "Value",        [Pct_Satisfied_With_WorkLifeBalance]),
        ROW("Driver", "Peer Relationship",  "Value",        [Pct_Satisfied_With_PeerRelationship])
    )
VAR TopRow =  TOPN(1, Drivers, [Value], ASC)
VAR TopValue = MAXX(TopRow, [Value])
RETURN
IF( ISBLANK(TopValue), "No data", TopValue)
______________________________________________________________________________

KPI - Low Driver Name =
VAR Drivers =
    UNION(
        ROW("Driver", "Management",         "Value",        [Pct_Satisfied_With_Management]),
        ROW("Driver", "Job Security",       "Value",        [Pct_Satisfied_With_JobSecurity]),
        ROW("Driver", "Compensation",       "Value",        [Pct_Satisfied_With_Compensation]),
        ROW("Driver", "Work-Life Balance",  "Value",        [Pct_Satisfied_With_WorkLifeBalance]),
        ROW("Driver", "Peer Relationship",  "Value",        [Pct_Satisfied_With_PeerRelationship])
    )
VAR TopRow =  TOPN(1, Drivers, [Value], ASC)
VAR TopName = MAXX(TopRow, [Driver])
RETURN
IF( ISBLANK(TopName), "No data", TopName)
______________________________________________________________________________

KPI - Low Engagement % =
DIVIDE(
    CALCULATE(
        COUNTROWS('dd_project hr_data'), 'dd_project hr_data'[Employee_Engagement_Score] <= 2),
        COUNTROWS('dd_project hr_data')
)
______________________________________________________________________________

KPI - Promotion Rate - High Training =
DIVIDE(
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        'dd_project hr_data'[Training_Hours] >= 20,
        'dd_project hr_data'[Promotion] = 1
    ),
    CALCULATE(
        COUNTROWS('dd_project hr_data'),
        'dd_project hr_data'[Training_Hours] >=20
    ),
    0
)
______________________________________________________________________________

KPI - Rolling Attrition Rate–Low Compesnation =
CALCULATE(
    [Rolling 12M Attrition Rate],
    'dd_project hr_data'[JobSatisfaction_Compensation] = 1
)
______________________________________________________________________________

KPI - Rolling Attrition Rate–Low Management =
CALCULATE(
    [Rolling 12M Attrition Rate],
    'dd_project hr_data'[JobSatisfaction_Management] = 1
)
______________________________________________________________________________

KPI - Rolling Attrition Rate–Low WorkLifeBalance =
CALCULATE(
    [Rolling 12M Attrition Rate],
    'dd_project hr_data'[JobSatisfaction_WorkLifeBalance] = 1
)
______________________________________________________________________________

KPI - Top Benefit Avg Engagement =
VAR PaidLeaveAvg    = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_PaidLeave] = 1)

VAR HealthAvg       = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 1)

VAR GymAvg          = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 1)

VAR RetirementAvg   = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_RetirementPlan] = 1)

VAR ChildCareAvg    = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_ChildCare] = 1)

RETURN
MAXX(
    {PaidLeaveAvg, HealthAvg, GymAvg, RetirementAvg, ChildCareAvg},
    [Value]
)
______________________________________________________________________________

KPI - Top Benefit Name =
VAR PaidLeaveAvg    = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_PaidLeave] = 1)

VAR HealthAvg       = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_HealthInsurance] = 1)

VAR GymAvg          = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_GymMembership] = 1)

VAR RetirementAvg   = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_RetirementPlan] = 1)

VAR ChildCareAvg    = CALCULATE(AVERAGE('dd_project hr_data'[Employee_Engagement_Score]), 'dd_project hr_data'[EmployeeBenefit_ChildCare] = 1)

VAR MaxVal = MAXX(
    {PaidLeaveAvg, HealthAvg, GymAvg, RetirementAvg, ChildCareAvg},
    [Value]
)

RETURN
SWITCH(
    TRUE(),
    MaxVal = PaidLeaveAvg, "Paid Leave",
    MaxVal = HealthAvg, "Health Insurance",
    MaxVal = GymAvg, "Gym Membership",
    MaxVal = RetirementAvg, "Retirement Plan",
    MaxVal = ChildCareAvg, "Child Care"
)
______________________________________________________________________________

KPI - Top Driver % =
VAR Drivers =
    UNION(
        ROW("Driver", "Management",         "Value",        [Pct_Satisfied_With_Management]),
        ROW("Driver", "Job Security",       "Value",        [Pct_Satisfied_With_JobSecurity]),
        ROW("Driver", "Compensation",       "Value",        [Pct_Satisfied_With_Compensation]),
        ROW("Driver", "Work-Life Balance",  "Value",        [Pct_Satisfied_With_WorkLifeBalance]),
        ROW("Driver", "Peer Relationship",  "Value",        [Pct_Satisfied_With_PeerRelationship])
    )
VAR TopRow =  TOPN(1, Drivers, [Value], DESC)
VAR TopValue = MAXX(TopRow, [Value])
RETURN
IF( ISBLANK(TopValue), "No data", TopValue)
______________________________________________________________________________

KPI - Top Driver Name =
VAR Drivers =
    UNION(
        ROW("Driver", "Management",         "Value",        [Pct_Satisfied_With_Management]),
        ROW("Driver", "Job Security",       "Value",        [Pct_Satisfied_With_JobSecurity]),
        ROW("Driver", "Compensation",       "Value",        [Pct_Satisfied_With_Compensation]),
        ROW("Driver", "Work-Life Balance",  "Value",        [Pct_Satisfied_With_WorkLifeBalance]),
        ROW("Driver", "Peer Relationship",  "Value",        [Pct_Satisfied_With_PeerRelationship])
    )
VAR TopRow =  TOPN(1, Drivers, [Value], DESC)
VAR TopName = MAXX(TopRow, [Driver])
RETURN
IF( ISBLANK(TopName), "No data", TopName)
______________________________________________________________________________
