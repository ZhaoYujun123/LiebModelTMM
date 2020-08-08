! --------------------------------------------------------------------
! TMMultLieb3DAtoB:
!
! 3D version of TMMult2D. Extra boundary conditions

SUBROUTINE TMMultLieb3DAtoB5(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara

  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output

  IMPLICIT NONE

  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width

  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy

  REAL(KIND=RKIND) PSI_A(M*M,M*M),PSI_B(M*M,M*M),OnsitePotVec(3*M,3*M)

  INTEGER jState, ISeedDummy,xSiteS,ySiteS, xSiteL,ySiteL
  REAL(KIND=RKIND) OnsitePot, OnsiteRight, OnsiteLeft, OnsiteUp, OnsiteDown
  REAL(KIND=RKIND) NEW, PsiLeft, PsiRight, PsiUp, PsiDown, stub

  INTEGER, PARAMETER :: LiebSpacer=3 

  INTEGER C2IL3
  EXTERNAL C2IL3

  !PRINT*,"DBG: TMMultLieb3DAtoB()"

  ! create the new onsite potential
!!$  DO xSiteS=1,LiebSpacer*M
!!$     DO ySiteS=1,LiebSpacer*M
!!$        SELECT CASE(IRNGFlag)
!!$        CASE(0)
!!$           OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
!!$        CASE(1)
!!$           OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
!!$        CASE(2)
!!$           OnsitePotVec(xSiteS,ySiteS)= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
!!$        END SELECT
!!$     END DO
!!$  END DO

  ! create the new onsite potential
  !  IRNGFlag=(xy)
  !  xy=0x      presenting conditions that all positions are disorder
  !  xy=x0,     presenting conditions that only central positions are disorder
  
  DO xSiteS=1,LiebSpacer*M
     Do ySiteS=1,LiebSpacer*M
        SELECT CASE(IRNGFlag)
        CASE(01)
           OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
        CASE(02)
           OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
        CASE(03)
           OnsitePotVec(xSiteS,ySiteS)= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
        CASE(10)
           IF(Mod(xSiteS,LiebSpacer)==1 .AND. Mod(ySiteS,LiebSpacer)==1) THEN
              OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
           ELSE
              OnsitePotVec(xSiteS,ySiteS)= -En + 0.0D0
           END IF
        CASE(20)
           IF(Mod(xSiteS,LiebSpacer)==1 .AND. Mod(ySiteS,LiebSpacer)==1) THEN
              OnsitePotVec(xSiteS,ySiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
           ELSE
              OnsitePotVec(xSiteS,ySiteS)= -En + 0.0D0
           END IF
        CASE(30)
           IF(Mod(xSiteS,LiebSpacer)==1 .AND. Mod(ySiteS,LiebSpacer)==1) THEN
              OnsitePotVec(xSiteS,ySiteS)= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
           ELSE
              OnsitePotVec(xSiteS,ySiteS)= -En + 0.0D0
           END IF
        END SELECT
     END DO
  END DO

  
  !to the TMM
  DO xSiteL=1,M
     DO ySiteL=1,M

        xSiteS= (xSiteL-1)*LiebSpacer + 1
        ySiteS= (ySiteL-1)*LiebSpacer + 1
        
!!$        PRINT*,"xL,yL, xS, yS, C2I", &
!!$             xSiteL,ySiteL, xSiteS,ySiteS, C2IL3(M,xSiteL,ySiteL)

        OnsitePot=OnsitePotVec(xSiteS,ySiteS)

        DO jState=1,M*M
           
           !PsiLeft
           IF (xSiteL.LE.1) THEN
              SELECT CASE(IBCFLag)
              CASE(-1,0) ! hard wall BC
                 OnsiteLeft= ZERO
                 PsiLeft= ZERO
              CASE(1) ! periodic BC
                 stub= OnsitePotVec(LiebSpacer*M,ySiteS)*OnSitePotVec(LiebSpacer*M-1,ySiteS)-1.0D0
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteLeft= OnsitePotVec(LiebSpacer*M-1,ySiteS) /stub
                 PsiLeft= Psi_A(C2IL3(M,M,ySiteL),jState) /stub
!              CASE(2) ! antiperiodic BC
              CASE DEFAULT
                 PRINT*,"TMMultLieb3DAtoB5(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
              END SELECT
           ELSE
              stub= OnsitePotVec(xSiteS-1,ySiteS)*OnSitePotVec(xSiteS-2,ySiteS)-1.0D0
              IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
              OnsiteLeft= OnsitePotVec(xSiteS-2,ySiteS) /stub
              PsiLeft= Psi_A(C2IL3(M,xSiteL-1,ySiteL),jState) /stub
           END IF

           !PsiRight
           IF (xSiteL.GE.M) THEN
              SELECT CASE(IBCFLag)
              CASE(-1) ! hard wall BC + stubs
                 stub= OnsitePotVec(xSiteS+1,ySiteS)*OnSitePotVec(xSiteS+2,ySiteS)-1.0D0
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteRight= OnsitePotVec(xSiteS+2,ySiteS)/stub
                 PsiRight= ZERO
              CASE(0) ! hard wall
                 OnsiteRight= ZERO
                 PsiRight= ZERO
              CASE(1) ! periodic BC
                 stub= OnsitePotVec(xSiteS+1,ySiteS)*OnSitePotVec(xSiteS+2,ySiteS)-1.0D0
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteRight= OnsitePotVec(xSiteS+2,ySiteS) /stub
                 PsiRight= Psi_A(C2IL3(M,1,ySiteL),jState) /stub
!              CASE(2) ! antiperiodic BC
              CASE DEFAULT
                 PRINT*,"TMMultLieb3DAtoB5(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
              END SELECT
           ELSE
              stub= OnsitePotVec(xSiteS+1,ySiteS)*OnSitePotVec(xSiteS+2,ySiteS)-1.0D0
              IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
              OnsiteRight= OnsitePotVec(xSiteS+2,ySiteS) /stub
              PsiRight= Psi_A(C2IL3(M,xSiteL+1,ySiteL),jState) /stub
           END IF

           !PsiDown
           IF (ySiteL.LE.1) THEN
              SELECT CASE(IBCFlag)
              CASE(-1,0) ! hard wall BC
                 OnsiteDown= ZERO
                 PsiDown= ZERO
              CASE(1) ! periodic BC
                 stub= (OnsitePotVec(xSiteS,LiebSpacer*M)*OnSitePotVec(xSiteS,LiebSpacer*M-1)-1.0D0)
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteDown= OnsitePotVec(xSiteS,LiebSpacer*M-1) /stub
                 PsiDown=  Psi_A(C2IL3(M,xSiteL,M),jState) /stub
              CASE(2) ! antiperiodic BC
              CASE DEFAULT
                 PRINT*,"TMMultLieb3DAtoB5(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
              END SELECT
           ELSE
              stub= OnsitePotVec(xSiteS,ySiteS-1)*OnSitePotVec(xSiteS,ySiteS-2)-1.0D0
              IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
              OnsiteDown= OnsitePotVec(xSiteS,ySiteS-2) /stub
              PsiDown= Psi_A(C2IL3(M,xSiteL,ySiteL-1),jState) /stub
           END IF

           !PsiUp
           IF (ySiteL.GE.M) THEN
              SELECT CASE(IBCFlag)
              CASE(-1) ! hard wall BC + stubs
                 stub= OnsitePotVec(xSiteS,ySiteS+1)*OnSitePotVec(xSiteS,ySiteS+2)-1.0D0
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteUp= OnsitePotVec(xSiteS,ySiteS+2) /stub
                 PsiUp= ZERO
              CASE(0) ! hard wall
                 OnsiteUp=ZERO
                 PsiUp= ZERO
              CASE(1) ! periodic BC
                 stub= OnsitePotVec(xSiteS,ySiteS+1)*OnSitePotVec(xSiteS,ySiteS+2)-1.0D0
                 IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
                 OnsiteUp= OnsitePotVec(xSiteS,ySiteS+2) /stub
                 PsiUp= Psi_A(C2IL3(M,xSiteL,1),jState) /stub
!              CASE(2) ! antiperiodic BC
              CASE DEFAULT
                 PRINT*,"TMMultLieb3DAtoB5(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
              END SELECT
           ELSE
              stub= OnsitePotVec(xSiteS,ySiteS+1)*OnSitePotVec(xSiteS,ySiteS+2)-1.0D0
              IF( ABS(stub).LT.TINY) stub= SIGN(TINY,stub)
              OnsiteUp= OnsitePotVec(xSiteS,ySiteS+2) /stub
              PsiUp= Psi_A(C2IL3(M,xSiteL,ySiteL+1),jState) /stub
           END IF

           NEW= ( OnsitePot - OnsiteLeft - OnsiteRight - OnsiteDown - OnsiteUp ) * &
                Psi_A(C2IL3(M,xSiteL,ySiteL),jState) &
                - Kappa * ( PsiLeft + PsiRight + PsiDown + PsiUp ) &
                - PSI_B(C2IL3(M,xSiteL,ySiteL),jState)
           
           PSI_B(C2IL3(M,xSiteL,ySiteL),jState)= NEW
        END DO !jState
        
     END DO !xSiteL
  END DO !ySiteL
  RETURN

END SUBROUTINE TMMultLieb3DAtoB5

!!$! --------------------------------------------------------------------
!!$! convert i,j coordinates to an index
!!$! used in lieb32/33
!!$FUNCTION Co2InL32(M, xSiteL, ySiteL)
!!$  INTEGER Co2InL32, M, xSiteL, ySiteL
!!$  
!!$  INTEGER Co2InL31
!!$  EXTERNAL Co2InL31
!!$
!!$  Co2InL32= Co2InL31(M,xSiteL,ySiteL)
!!$  
!!$  RETURN
!!$END FUNCTION Co2InL32
!!$
! --------------------------------------------------------------------
! TMMultLieb3DBtoA:
!
! 3D version of TMMult2D. Extra boundary conditions

SUBROUTINE TMMultLieb3DB5toB6(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara
  
  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output
  
  IMPLICIT NONE
  
  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width
  
  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy
  
  REAL(KIND=CKIND) PSI_A(M*M,M*M), PSI_B(M*M,M*M)
  
  INTEGER iSite, jState, ISeedDummy
  REAL(KIND=RKIND) OnsitePot
  REAL(KIND=CKIND) NEW
  
  !PRINT*,"DBG: TMMultLieb3DBtoA()"
  
  DO iSite=1,M*M
     
     ! create the new onsite potential
!!$     SELECT CASE(IRNGFlag)
!!$     CASE(0)
!!$        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
!!$     CASE(1)
!!$        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
!!$     CASE(2)
!!$        OnsitePot= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
!!$     END SELECT

     SELECT CASE(IRNGFlag)
     CASE(01)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
     CASE(02)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
     CASE(03)
        OnsitePot= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
     CASE(10)
        OnsitePot= -En + 0.0D0
     CASE(20)
        OnsitePot= -En + 0.0D0
     CASE(30)
        OnsitePot= -En + 0.0D0
     END SELECT
     
     !PRINT*,"iS,pL,RndVec", iSite,pLevel,RndVec((pLevel-1)*M+iSite)
     
     DO jState=1,M*M
        
        !PRINT*,"jState, iSite", jState, iSite,
!!$        
!!$        NEW= ( OnsitePot * PSI_A(jState,iSite) &
!!$             - PSI_B(jState,iSite) )
        NEW=  OnsitePot * PSI_A(iSite,jState) &
             - PSI_B(iSite,jState) 
        
        !PRINT*,"i,jSite,En, OP, PL, PR, PA,PB, PN"
        !PRINT*, iSite, jState, En, OnsitePot, PsiLeft, PsiRight,
        !        PSI_A(iSite,jState), PSI_B(iSite,jState),
        !        new
        
!!$        PSI_B(jState,iSite)= NEW
        PSI_B(iSite,jState)= NEW
        
     ENDDO ! jState
  ENDDO ! iSite
  
  RETURN
END SUBROUTINE TMMultLieb3DB5toB6

SUBROUTINE TMMultLieb3DB6toA(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara
  
  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output
  
  IMPLICIT NONE
  
  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width
  
  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy
  
  REAL(KIND=CKIND) PSI_A(M*M,M*M), PSI_B(M*M,M*M)
  
  CALL TMMultLieb3DB5toB6(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  RETURN
END SUBROUTINE TMMultLieb3DB6toA
