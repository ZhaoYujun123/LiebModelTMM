! --------------------------------------------------------------------
! TMMultLieb2DAtoB:
!
! Multiplication of the transfer matrix onto the vector (PSI_A,PSI_B), 
! giving (PSI_B,PSI_A) so that the structure of the transfer matrix 
! can be exploited

SUBROUTINE TMMultLieb2DAtoB(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

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
  
  REAL(KIND=CKIND) PSI_A(M,M), PSI_B(M,M)
  
  INTEGER iSiteL,iSiteS, jState, ISeedDummy
  REAL(KIND=RKIND) OnsitePot, OnsiteRight, OnsiteLeft, OnsitePotVec(2*M)
  REAL(KIND=CKIND) new , PsiLeft, PsiRight
  
  !PRINT*,"DBG: TMMultLieb2DAtoB()"

  ! create the new onsite potential
  DO iSiteS=1,2*M   
     SELECT CASE(IRNGFlag)
     CASE(0)
        OnsitePotVec(iSiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
     CASE(1)
        OnsitePotVec(iSiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
     CASE(2)
        OnsitePotVec(iSiteS)= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
     END SELECT

     IF( ABS(OnsitePotVec(iSiteS)).LT.TINY) THEN
        OnsitePotVec(iSiteS)= SIGN(TINY,OnsitePotVec(iSiteS))
     END IF
  END DO
     
  ! to the TMM
  DO iSiteL=1,M
     
     !PRINT*,"iS,pL,RndVec", iSite,pLevel,RndVec((pLevel-1)*M+iSite)
     iSiteS= 2*iSiteL-1
     
     OnsitePot= &
          OnsitePotVec(iSiteS) !+ 1.D0/(OnsitePotVec(iSite-1) + 1.D0/(OnsitePotVec(iSite+1)
     
     DO jState=1,M
        
        !PRINT*,"jState, iSite", jState, iSite,
        !Up
        IF (iSiteL.EQ.1) THEN
           SELECT CASE(IBCFlag)
           CASE(-1,0) ! hard wall BC
              PsiLeft= ZERO            
              OnsiteLeft= ZERO
           CASE(1) ! periodic BC
              PsiLeft= PSI_A(M,jState)/OnsitePotVec(2*M)
              OnsiteLeft= 1.D0/OnsitePotVec(2*M)
           CASE(2) ! antiperiodic BC
              PsiLeft= -PSI_A(M,jState)/OnsitePotVec(2*M) 
              OnsiteLeft= 1.D0/OnsitePotVec(2*M)
           CASE DEFAULT
              PRINT*,"TMMultLieb2DAtoB(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
           END SELECT
        ELSE
           PsiLeft= PSI_A(iSiteL-1,jState)/OnsitePotVec(iSiteS -1)
           OnsiteLeft= 1.D0/OnsitePotVec(iSiteS -1)
        END IF

        !Down
        IF (iSiteL.EQ.M) THEN
           SELECT CASE(IBCFlag)
           CASE(-1) ! hard wall BC + STUBS
              PsiRight= ZERO            
              OnsiteRight= 1.D0/OnsitePotVec(iSiteS +1)
           CASE(0) ! hard wall BC
              PsiRight= ZERO            
              OnsiteRight= ZERO
           CASE(1) ! periodic BC
              PsiRight= PSI_A(1,jState)/OnsitePotVec(iSiteS +1) 
              OnsiteRight= 1.D0/OnsitePotVec(iSiteS +1)
           CASE(2) ! antiperiodic BC
              PsiRight= -PSI_A(1,jState)/OnsitePotVec(iSiteS +1)
              OnsiteRight= 1.D0/OnsitePotVec(iSiteS +1)
           CASE DEFAULT
              PRINT*,"TMMultLieb2DAtoB(): IBCFlag=", IBCFlag, " not implemented --- WRNG!"
           END SELECT
        ELSE
           PsiRight= PSI_A(iSiteL+1,jState)/OnsitePotVec(iSiteS +1)
           OnsiteRight= 1.D0/OnsitePotVec(iSiteS +1)
        END IF
        
        new =(( OnsitePot-OnsiteLeft-OnsiteRight ) * PSI_A(iSiteL,jState) &
             - Kappa * ( PsiLeft + PsiRight ) &
             - PSI_B(iSiteL,jState) )
        
        !PRINT*,"i,j,En, OP, PL, PR, PA,PB, PN"
        !PRINT*, iSite, jState, En, OnsitePot, PsiLeft, PsiRight,
        !        PSI_A(iSite,jState), PSI_B(iSite,jState),
        !        new
        
        PSI_B(iSiteL,jState)= new
        
     ENDDO ! jState
  ENDDO ! iSite
  
  !PRINT*,"PSIA(1,1),(1,2),(1,3),(1,4)",&
        !PSI_A(1,1),PSI_A(1,2),PSI_A(1,3),PSI_A(1,4)

  !PRINT*,"PSIB(1,1),(1,2),(1,3),(1,4)",&
        !PSI_B(1,1),PSI_B(1,2),PSI_B(1,3),PSI_B(1,4)
  
  RETURN
END SUBROUTINE TMMultLieb2DAtoB

! --------------------------------------------------------------------
! TMMultLieb2DBtoA:
!
! Multiplication of the transfer matrix onto the vector (PSI_A,PSI_B), 
! giving (PSI_B,PSI_A) so that the structure of the transfer matrix 
! can be exploited

SUBROUTINE TMMultLieb2DBtoA(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

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
  
  REAL(KIND=CKIND) PSI_A(M,M), PSI_B(M,M)
  
  INTEGER iSite, jState, ISeedDummy
  REAL(KIND=RKIND) OnsitePot
  REAL(KIND=CKIND) new
  
  !PRINT*,"DBG: TMMultLieb2DBtoA()"
  
  DO iSite=1,M
     
     ! create the new onsite potential
     SELECT CASE(IRNGFlag)
     CASE(0)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
     CASE(1)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
     CASE(2)
        OnsitePot= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
     END SELECT
     
     !PRINT*,"iS,pL,RndVec", iSite,pLevel,RndVec((pLevel-1)*M+iSite)
     
     DO jState=1,M
        
        !PRINT*,"jState, iSite", jState, iSite,
        
        new= ( OnsitePot * PSI_A(iSite,jState) &
             - PSI_B(iSite,jState) )
        
        !PRINT*,"i,j,En, OP, PL, PR, PA,PB, PN"
        !PRINT*, iSite, jState, En, OnsitePot, PsiLeft, PsiRight,
        !        PSI_A(iSite,jState), PSI_B(iSite,jState),
        !        new
        
        PSI_B(iSite,jState)= new
        
     ENDDO ! jState
  ENDDO ! iSite
  
  !PRINT*,"PSIA(1,1),(1,2),(1,3),(1,4)",&
        !PSI_A(1,1),PSI_A(1,2),PSI_A(1,3),PSI_A(1,4)

  !PRINT*,"PSIB(1,1),(1,2),(1,3),(1,4)",&
        !PSI_B(1,1),PSI_B(1,2),PSI_B(1,3),PSI_B(1,4)
  
  RETURN
END SUBROUTINE TMMultLieb2DBtoA

