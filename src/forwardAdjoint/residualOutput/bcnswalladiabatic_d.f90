   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.6 (r4159) - 21 Sep 2011 10:11
   !
   !  Differentiation of bcnswalladiabatic in forward (tangent) mode:
   !   variations   of useful results: *rev *bvtj1 *bvtj2 *p *gamma
   !                *bmtk1 *w *bmtk2 *rlv *bvtk1 *bvtk2 *bmti1 *bmti2
   !                *bvti1 *bvti2 *bmtj1 *bmtj2
   !   with respect to varying inputs: *rev *p *w *rlv rgas
   !   Plus diff mem management of: rev:in bvtj1:in bvtj2:in p:in
   !                gamma:in bmtk1:in w:in bmtk2:in rlv:in bvtk1:in
   !                bvtk2:in d2wall:in bmti1:in bmti2:in bvti1:in
   !                bvti2:in bmtj1:in bmtj2:in bcdata:in *bcdata.uslip:in
   !                (global)cphint:in-out
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcNsWallAdiabatic.f90                           *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-10-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCNSWALLADIABATIC_D(secondhalo, correctfork)
   USE FLOWVARREFSTATE
   USE BLOCKPOINTERS_D
   USE BCTYPES
   USE CONSTANTS
   USE ITERATION
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcNSWallAdiabatic applies the viscous adiabatic wall           *
   !      * boundary condition to a block. It is assumed that the pointers *
   !      * in blockPointers are already set to the correct block on the   *
   !      * correct grid level.                                            *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !      Subroutine arguments.
   !
   LOGICAL, INTENT(IN) :: secondhalo, correctfork
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: nn, i, j
   REAL(kind=realtype) :: rhok
   REAL(kind=realtype) :: rhokd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: uslip
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d, rev2d
   INTERFACE 
   SUBROUTINE SETBCPOINTERS(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &        rev1, rev2, offset)
   USE BLOCKPOINTERS_D
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   END SUBROUTINE SETBCPOINTERS
   END INTERFACE
      INTERFACE 
   SUBROUTINE SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, &
   &        pp2, pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev1d, rev2, rev2d, &
   &        offset)
   USE BLOCKPOINTERS_D
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d, rev2d
   END SUBROUTINE SETBCPOINTERS_D
   END INTERFACE
      !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! In case the turbulent transport equations are solved
   ! together with the mean flow equations, aplly the viscous
   ! wall boundary conditions for the turbulent variables.
   ! No need to extrapolate the secondary halo's, because this
   ! is done in extrapolate2ndHalo.
   IF (turbcoupled) THEN
   bmtj2d = 0.0
   bmtj1d = 0.0
   bvti2d = 0.0
   bvti1d = 0.0
   bmti2d = 0.0
   bmti1d = 0.0
   bvtk2d = 0.0
   bvtk1d = 0.0
   bmtk2d = 0.0
   bmtk1d = 0.0
   bvtj2d = 0.0
   bvtj1d = 0.0
   CALL TURBBCNSWALL_D(.false.)
   gammad = 0.0
   ELSE
   bvtj1d = 0.0
   bvtj2d = 0.0
   gammad = 0.0
   bmtk1d = 0.0
   bmtk2d = 0.0
   bvtk1d = 0.0
   bvtk2d = 0.0
   bmti1d = 0.0
   bmti2d = 0.0
   bvti1d = 0.0
   bvti2d = 0.0
   bmtj1d = 0.0
   bmtj2d = 0.0
   END IF
   ! Loop over the viscous subfaces of this block. Note that
   ! these are numbered first.
   bocos:DO nn=1,nviscbocos
   ! Check for adiabatic viscous wall boundary conditions.
   IF (bctype(nn) .EQ. nswalladiabatic) THEN
   ! Set the pointer for uSlip to make the code more readable.
   uslip => bcdata(nn)%uslip
   ! Nullify the pointers and set them to the correct subface.
   ! They are nullified first, because some compilers require
   ! that.
   !nullify(ww1, ww2, pp1, pp2, rlv1, rlv2, rev1, rev2)
   CALL SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, pp2, &
   &                     pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev1d, rev2, &
   &                     rev2d, 0)
   ! Initialize rhok to zero. This will be overwritten if a
   ! correction for k must be applied.
   rhok = zero
   rhokd = 0.0
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   ! Set the value of rhok if a correcton must be applied.
   ! It probably does not matter too much, because k is very
   ! small near the wall.
   IF (correctfork) THEN
   rhokd = ww2d(i, j, irho)*ww2(i, j, itu1) + ww2(i, j, irho)*&
   &              ww2d(i, j, itu1)
   rhok = ww2(i, j, irho)*ww2(i, j, itu1)
   END IF
   ! Determine the variables in the halo. As the spacing
   ! is very small a constant pressure boundary condition
   ! (except for the k correction) is okay. Take the slip
   ! velocity into account.
   ww1d(i, j, irho) = ww2d(i, j, irho)
   ww1(i, j, irho) = ww2(i, j, irho)
   ww1d(i, j, ivx) = -ww2d(i, j, ivx)
   ww1(i, j, ivx) = -ww2(i, j, ivx) + two*uslip(i, j, 1)
   ww1d(i, j, ivy) = -ww2d(i, j, ivy)
   ww1(i, j, ivy) = -ww2(i, j, ivy) + two*uslip(i, j, 2)
   ww1d(i, j, ivz) = -ww2d(i, j, ivz)
   ww1(i, j, ivz) = -ww2(i, j, ivz) + two*uslip(i, j, 3)
   pp1d(i, j) = pp2d(i, j) - four*third*rhokd
   pp1(i, j) = pp2(i, j) - four*third*rhok
   ! Set the viscosities. There is no need to test for a
   ! viscous problem of course. The eddy viscosity is
   ! set to the negative value, as it should be zero on
   ! the wall.
   rlv1d(i, j) = rlv2d(i, j)
   rlv1(i, j) = rlv2(i, j)
   IF (eddymodel) THEN
   rev1d(i, j) = -rev2d(i, j)
   rev1(i, j) = -rev2(i, j)
   END IF
   END DO
   END DO
   ! Compute the energy for these halo's.
   CALL COMPUTEETOT_D(icbeg(nn), icend(nn), jcbeg(nn), jcend(nn), &
   &                   kcbeg(nn), kcend(nn), correctfork)
   ! Extrapolate the state vectors in case a second halo
   ! is needed.
   IF (secondhalo) CALL EXTRAPOLATE2NDHALO_D(nn, correctfork)
   END IF
   END DO bocos
   END SUBROUTINE BCNSWALLADIABATIC_D
