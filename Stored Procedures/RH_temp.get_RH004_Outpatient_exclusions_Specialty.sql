SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [RH_temp].[get_RH004_Outpatient_exclusions_Specialty]
AS
    BEGIN
        SET XACT_ABORT, NOCOUNT ON;

        DROP TABLE IF EXISTS RH_temp.Outpatient_exclusions_Specialty;

        CREATE TABLE [RH_temp].[Outpatient_exclusions_Specialty]
            (
                [source_site]                    [CHAR](3)      NOT NULL
                , [source_system]                [VARCHAR](255) NOT NULL
                , [attendance_id]                [VARCHAR](255) NOT NULL
                , [alternate_attendance_id]      [VARCHAR](255) NOT NULL
                , [location]                     [VARCHAR](255) NULL
                , [admin_category]               [VARCHAR](255) NULL
                , [first_attendance]             [VARCHAR](255) NULL
                , [outcome_of_attendance]        [VARCHAR](255) NULL
                , [attended_did_not_attend]      [VARCHAR](255) NULL
                , [attendance_datetime]          [DATETIME2](3) NULL
                , [expected_duration]            [INT]          NULL
                , [arrival_datetime]             [DATETIME2](3) NULL
                , [seen_datetime]                [DATETIME2](3) NULL
                , [book_in_datetime]             [DATETIME2](3) NULL
                , [book_out_datetime]            [DATETIME2](3) NULL
                , [booked_datetime]              [DATETIME2](3) NULL
                , [booked_by_user_account]       [VARCHAR](255) NULL
                , [clinic]                       [VARCHAR](255) NULL
                , [responcible_clinician]        [VARCHAR](255) NULL
                , [patient]                      [VARCHAR](255) NULL
                , [main_specialty]               [VARCHAR](255) NULL
                , [treatment_function_specialty] [VARCHAR](255) NULL
                , [consultation_medium_used]     [VARCHAR](255) NULL
                , [outpatient_visit_type]        [VARCHAR](255) NULL
                , [operation_status]             [VARCHAR](255) NULL
                , [rtt_outcome]                  [VARCHAR](255) NULL
                , [attendance_req_clinic_letter] [BIT]          NULL
				, AppointmentTypeID  VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , [updated_dttm]                 [DATETIME2](3) NOT NULL
				,
            ) ON [PRIMARY];

        --	SCH Referral - Appointment data
        CREATE TABLE #SchRefAppt
            (
                SourceID        VARCHAR(3)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , AppointmentID VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , ReferralID    VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , CONSTRAINT pk_temp86434983
                      PRIMARY KEY CLUSTERED (SourceID, AppointmentID, ReferralID)
            );

        INSERT #SchRefAppt
            (
                SourceID
                , AppointmentID
                , ReferralID
            )
               SELECT RA.SourceID
                      , RA.AppointmentID
                      , RA.ReferralID
               FROM   MeditechV6n_Stg.dbo.SchUkReferralAppointments RA
               WHERE  RA.SourceID = 'BUR';

        --	SCH Appointment data
        CREATE TABLE #SchAppts
            (
                SourceID            VARCHAR(3)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , VisitID           VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , AppointmentID     VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
                , PatientID         VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , ApptDateTime      DATETIME     NOT NULL
                , InDateTime        DATETIME     NULL
                , OutDateTime       DATETIME     NULL
                , SeenDateTime      DATETIME     NULL
                , ProviderID        VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , ProviderType      VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , AppointmentTypeID VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , RTT_OutcomeID     VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
                , Duration          INT          NULL
                , CONSTRAINT pk_temp12687493
                      PRIMARY KEY CLUSTERED (SourceID, VisitID, AppointmentID)
            );

        INSERT #SchAppts
            (
                SourceID
                , VisitID
                , AppointmentID
                , PatientID
                , ApptDateTime
                , InDateTime
                , OutDateTime
                , SeenDateTime
                , ProviderID
                , ProviderType
                , AppointmentTypeID
                , RTT_OutcomeID
                , Duration
            )
               SELECT A.SourceID
                      , A.VisitID
                      , A.AppointmentID
                      , A.PatientID
                      , A.[DateTime]
                      , A.InDateTime
                      , A.OutDateTime
                      , A.SeenDateTime
                      , A.ProviderID
                      , P.ProviderType
                      , A.AppointmentTypeID
                      , UA.OutcomeID
                      , A.Duration
               --SELECT TOP (1100) *
               FROM   MeditechV6n_Stg.dbo.SchAppointments             A
                      LEFT JOIN MeditechV6n_Stg.dbo.SchUkAppointments UA
                             ON UA.SourceID = A.SourceID
                                AND UA.AppointmentID = A.AppointmentID
                      OUTER APPLY (
                                  SELECT _p.ProviderTypeID
                                  FROM   MeditechV6n_Stg.dbo.DMisProvider _p -- AH 01 Nov 2018 - Post-6.08
                                  WHERE  _p.SourceID       = A.SourceID
                                         AND _p.ProviderID = A.ProviderID
                                  )                                   P(ProviderType)
               WHERE  A.SourceID     = 'BUR'
                      AND A.VisitID IS NOT NULL
                      AND A.[Status] = 'ATTENDED';

        INSERT RH_temp.RH004_Outpatient_exclusions
            (
                source_site
                , source_system
                , attendance_id
                , alternate_attendance_id
                , [location]
                , admin_category
                , first_attendance
                , outcome_of_attendance
                , attended_did_not_attend
                , attendance_datetime
                , expected_duration
                , arrival_datetime
                , seen_datetime
                , book_in_datetime
                , book_out_datetime
                , booked_datetime
                , booked_by_user_account
                , clinic
                , responcible_clinician
                , patient
                , main_specialty
                , treatment_function_specialty
                , consultation_medium_used
                , outpatient_visit_type
                , operation_status
                , rtt_outcome
                , attendance_req_clinic_letter
				,appointmenttypeid
                , updated_dttm
            )
               SELECT AD.SourceID                                            AS [source_site]
                      , 'MEDITECH'                                           AS [source_system]
                      , AD.AccountNumber                                     AS [attendance_id]
                      , AD.VisitID                                           AS [alternate_attendance_id]
                      , AD.LocationID                                        AS [location]
                      , AD.FinancialClassID                                  AS [admin_category]
                      , CASE
                            WHEN dSAT.ConsultationMedium IN ( 'Phone', 'Talk Type', 'Telemedicine' )
                                 OR APUO.ConsultationMedium IN ( 'Phone', 'Talk Type', 'Telemedicine' ) -- AH 30 Apr 2020 - Added
                                 OR AD.LocationID = 'TELEPHONE'
                            THEN CASE C.VisitType
                                     WHEN 'N'
                                     THEN '3'
                                     ELSE '4'
                                 END
                            ELSE --	assumes 'Face to Face'
                            CASE C.VisitType
                                WHEN 'N'
                                THEN '1'
                                ELSE '2'
                            END
                        END                                                  AS [first_attendance]
                      , CASE
                            WHEN FA.EventType = 'BOOK'
                            THEN '2'
                            WHEN FA.EventType = 'PEND'
                            THEN '3'
                            /*    AH    14 Feb 2022 - added at KB req 09 Feb    */
                            WHEN EXISTS (
                                        SELECT *
                                        FROM   MeditechV6n_Stg.dbo.DMisUkOutcomeCodes _c
                                        WHERE  _c.SourceID      = TSA.SourceID
                                               AND _c.OutcomeID = TSA.RTT_OutcomeID
                                               AND _c.AbsTapeID = 'CDS'
                                               AND _c.AbsTapeCode IN ( '10', '11', '12', '20' )
                                        )
                            THEN '3'
                            ELSE '1'
                        END                                                  AS [outcome_of_attendance]
                      , CASE
                            WHEN AD.AdmitDateTime > TSA.ApptDateTime
                            THEN 6
                            ELSE 5
                        END                                                  AS [attended_did_not_attend]
                      , ISNULL(TSA.ApptDateTime, AD.AdmitDateTime)           AS [attendance_datetime]
                      , TSA.Duration                                         AS [expected_duration]
                      , AD.AdmitDateTime                                     AS [arrival_datetime]
                      , TSA.SeenDateTime                                     AS [seen_datetime]
                      , TSA.InDateTime                                       AS [book_in_datetime]
                      , TSA.OutDateTime                                      AS [book_out_datetime]
                      , AE.ActualEventDateTime                               AS [booked_datetime]
                      , AE.EventUserID                                       AS [booked_by_user_account]
                      , TSA.AppointmentTypeID                                AS [clinic]
                      , C.ProviderID                                         AS [responcible_clinician]
                      , AD.UnitNumber                                        AS [patient]
                      , ISNULL(   AV.InpatientServiceID -- AH 08 Mar 2021
                                  , dP.ServiceID
                              )                                              AS [main_specialty]
                      , ISNULL(GMS.SubSpecialtyID, AD.DischargeAbsServiceID) AS [treatment_function_specialty]
                      , CASE
                            WHEN APU.ReferralSourceID = 'IPC'
                            THEN '01' -- assumes 'Face to Face'
                            ELSE CASE
                                     WHEN APUO.ConsultationMedium = 'Telemedicine' ------------\
                                          OR dSAT.ConsultationMedium = 'Telemedicine'
                                     THEN '03' -- AH 12 May 2020 - Added
                                     WHEN APUO.ConsultationMedium = 'Talk Type' ------------\
                                          OR dSAT.ConsultationMedium = 'Talk Type'
                                     THEN '04' -- AH 12 May 2020 - Added
                                     WHEN APUO.ConsultationMedium = 'Phone' -- AH 30 Apr 2020 - Added
                                          OR dSAT.ConsultationMedium = 'Phone'
                                     THEN '02'
                                     WHEN APUO.ConsultationMedium = 'Face to Face'
                                          OR dSAT.ConsultationMedium = 'Face to Face'
                                     THEN '01'
                                 END
                        END                                                  AS [consultation_medium_used]
                      , CASE
                            WHEN APU.ReferralSourceID = 'IPC'
                            THEN 'IPC'
                            WHEN EXISTS (
                                        SELECT *
                                        FROM   dw_pre_staging.outpatient.provider_types_BUR
                                        WHERE  provider_type_role = 'WA'
                                               AND provider_type  = C.ProviderType
                                        )
                                 AND (
                                     EXISTS (
                                            SELECT *
                                            FROM   dw_pre_staging.outpatient.wa_locations_BUR
                                            WHERE  location_id = AD.LocationID
                                            )
                                     OR AD.LocationID LIKE 'BH[0-9]%'
                                     )
                            THEN 'WA'
                            WHEN C.ProviderID = 'PREOPNURSE' -- special case
                            THEN 'NonCons' --/
                            WHEN EXISTS (
                                        SELECT *
                                        FROM   dw_pre_staging.outpatient.provider_types_BUR
                                        WHERE  provider_type_role = 'Cons'
                                               AND provider_type  = C.ProviderType
                                        )
                            THEN 'Cons'
                            ELSE 'NonCons'
                        END                                                  AS [outpatient_visit_type]
                      , '9'                                                  AS [operation_status]             -- update post, procedure load
                      , TSA.RTT_OutcomeID                                    AS [rtt_outcome]
                      , 1                                                    AS [attendance_req_clinic_letter] -- post processing
                      ,TSA.AppointmentTypeID AS [AppointmentTypeID]
					  , GETDATE()                                            AS [updated_dttm]
               FROM   MeditechV6n_Stg.dbo.AbstractData          AD
                      LEFT JOIN MeditechV6n_Stg.dbo.AbsServices ASS -- used for clinicians (seen by) as well ??
                             ON ASS.SourceID = AD.SourceID
                                AND ASS.AbstractID = AD.AbstractID
                                AND ASS.ServiceSeqID = 1
                      OUTER APPLY (
                                  SELECT _p.ProviderTypeID
                                  FROM   MeditechV6n_Stg.dbo.DMisProvider _p -- AH 01 Nov 2018 - Post-6.08
                                  WHERE  _p.SourceID       = ASS.SourceID
                                         AND _p.ProviderID = ASS.ProviderID
                                  )                             P(ProviderType)
                      OUTER APPLY (
                                  SELECT _apu.ReferralSourceID
                                         , _apu.VisitType
                                  FROM   MeditechV6n_Stg.dbo.AbsPatUks _apu
                                  WHERE  _apu.SourceID       = AD.SourceID
                                         AND _apu.AbstractID = AD.AbstractID
                                  ) APU

                      /*    AH    08 Mar 2021        -    new source for main spec     */
                      LEFT JOIN MeditechV6n_Stg.dbo.AdmVisits     AV
                             ON AV.SourceID = AD.SourceID
                                AND AV.VisitID = AD.VisitID
                      LEFT JOIN MeditechV6n_Stg.dbo.AdmPatUkOther APUO -- AH 30 Apr 2020
                             ON APUO.SourceID = AD.SourceID
                                AND APUO.VisitID = AD.VisitID
                      OUTER APPLY (
                                  SELECT TOP (1)
                                         *
                                  FROM   #SchAppts     _tsa
                                         CROSS APPLY (
                                                     VALUES (ABS(DATEDIFF(MINUTE, AD.AdmitDateTime, _tsa.ApptDateTime)))
                                                     ) _c (date_prox)
                                  WHERE  _tsa.SourceID    = AD.SourceID
                                         AND _tsa.VisitID = AD.VisitID
                                  ORDER BY
                                         _c.date_prox
                                  )                               TSA
                      CROSS APPLY (
                                  VALUES (CONVERT(DATE, TSA.ApptDateTime))
                                  ) C0 (EventDate) -- strip time
                      OUTER APPLY (
                                  SELECT TOP (1)
                                         _ae.[Type]
                                  FROM   #SchRefAppt                                        _tsar
                                         JOIN MeditechV6n_Stg.dbo.SchUkReferralAppointments _sra_out
                                           ON _sra_out.SourceID          = _tsar.SourceID
                                              AND _sra_out.ReferralID    = _tsar.ReferralID
                                              AND _sra_out.AppointmentID <> _tsar.AppointmentID
                                         JOIN MeditechV6n_Stg.dbo.SchAppointmentEvents      _ae
                                           ON _ae.SourceID               = _sra_out.SourceID
                                              AND _ae.AppointmentID      = _sra_out.AppointmentID
                                              AND _ae.EventDateTime      >= C0.EventDate
                                              AND (
                                                  (
                                                  _ae.EventDateTime      < DATEADD(DAY, 2, C0.EventDate)
                                                  AND _ae.[Type]         = 'BOOK'
                                                  )
                                                  OR (
                                                     _ae.EventDateTime   < DATEADD(DAY, 5, C0.EventDate)
                                                     AND _ae.[Type]      = 'PEND'
                                                     )
                                                  )
                                  WHERE  _tsar.SourceID          = TSA.SourceID
                                         AND _tsar.AppointmentID = TSA.AppointmentID
                                  ORDER BY
                                         _ae.[Type]
                                  ) FA(EventType)
                      OUTER APPLY (
                                  SELECT TOP (1)
                                         _ae.EventUserID
                                         , _ae.ActualEventDateTime
                                  FROM   MeditechV6n_Stg.dbo.SchAppointmentEvents _ae
                                  WHERE  _ae.SourceID          = TSA.SourceID
                                         AND _ae.AppointmentID = TSA.AppointmentID
                                         AND _ae.EventDateTime <= AD.AdmitDateTime
                                         AND _ae.[Type]        = 'BOOK'
                                  ORDER BY
                                         _ae.ActualEventDateTime DESC
                                  ) AE
                      LEFT JOIN MeditechV6n_Stg.dbo.DSchApptTypeUks dSAT
                             ON dSAT.SourceID = TSA.SourceID
                                AND dSAT.AppointmentTypeID = TSA.AppointmentTypeID
                      CROSS APPLY (
                                  VALUES (COALESCE(APU.VisitType, dSAT.DefaultVisitTypeID)
                                          , COALESCE(TSA.ProviderID, ASS.ProviderID)
                                          , COALESCE(TSA.ProviderType, P.ProviderType)
                                          , AD.UnitNumber COLLATE Latin1_General_CI_AS -- AH 04 Nov 2019
                                         )
                                  )                                 C (VisitType, ProviderID, ProviderType, UnitNumber)
                      LEFT JOIN MeditechV6n_Stg.dbo.DMisProvider dP
                             ON dP.SourceID = AD.SourceID
                                AND dP.ProviderID = C.ProviderID
                      CROSS APPLY (
                                  VALUES (C.ProviderID COLLATE Latin1_General_CI_AS)
                                  )                              Co (nsultantID)

                      /*    AH    10 Sep 2019        Vicky P req in DE absence    */
                      OUTER APPLY (
                                  SELECT TOP (1)
                                         _gms.SubSpecialtyID
                                  FROM   dw_pre_staging.reference.consultant_gen_med_split_BUR _gms
                                  WHERE  _gms.ConsultantID = Co.nsultantID
                                         AND dP.ServiceID  = 'GMED'
                                  ORDER BY
                                         _gms.SubSpecialtyID
                                  ) GMS
               WHERE  AD.SourceID          = 'BUR'
                      AND AD.PtStatus      = 'CLI'
                      AND AD.AdmitDateTime >= '01 Apr 2016'
                      /*    AH    12 Jul 2019        - DE request e-mail to exclude from OP data    */
                      		AND dP.ServiceID IN ('PHOTO', 'RESEARCH', 'SOCWORK', 'VASCULAR', 'DOC')
                      --AND dP.ServiceID IN ( 'VASCULAR', 'DOC' )
                      /*    AH    27 Jul 2023 - excl RESP CAS virtual clinic    */
                      --AND (TSA.AppointmentTypeID IS NULL
                      -- OR TSA.AppointmentTypeID <> 'BHRESPCAS')
					  --AND TSA.AppointmentTypeID = 'BHRESPCAS'

                      /*    AH    04 Nov 2019        - requirement to exclude test patients from OP data    */
                      AND NOT EXISTS (
                                     SELECT *
                                     FROM   dw_pre_staging.patient.test_patients _tp
                                     WHERE  _tp.source_site          = 'BUR'
                                            AND _tp.local_pas_number = C.UnitNumber
                                     )
									 OPTION (QUERYTRACEON 9481);	

        DROP TABLE #SchAppts;
        DROP TABLE #SchRefAppt;
    END;
GO
