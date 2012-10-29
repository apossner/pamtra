subroutine rain_ssp(f,rwc,cwc,t,maxleg,nc,kext, salb, back,  &
     nlegen, legen, legen2, legen3, legen4,&
     scatter_matrix,extinct_matrix, emis_vector)

  use kinds
  use nml_params, only: verbose, lphase_flag, n_0rainD, SD_rain, &
	  n_moments,nstokes, EM_rain, use_rain_db
  use constants, only: pi, im
  use double_moments_module
  use conversions

  implicit none

  integer :: nbins, nlegen
  integer, intent(in) :: maxleg
    integer, parameter ::  nquad = 16
  real(kind=dbl), intent(in) :: &
       rwc,&
       cwc,&
       t,&
       f

  real(kind=dbl), intent(in) :: nc

  real(kind=dbl) :: refre, refim

  real(kind=dbl) :: absind, abscof

  real(kind=dbl) :: dia1, dia2, den_liq, ad, bd, alpha, gamma, b_rain, a_mrain
    real(kind=dbl), dimension(nstokes,nquad,nstokes,nquad,4), intent(out) :: scatter_matrix
    real(kind=dbl), dimension(nstokes,nstokes,nquad,2), intent(out) :: extinct_matrix
    real(kind=dbl), dimension(nstokes,nquad,2), intent(out) :: emis_vector
  real(kind=dbl), intent(out) :: &
       kext,&
       salb,&
       back

  real(kind=dbl), dimension(200):: legen, legen2, legen3, legen4

  complex(kind=dbl) :: mindex

  real(kind=dbl) :: gammln

  if (verbose .gt. 1) print*, 'Entering rain_ssp'
  if ((n_moments .eq. 1) .and. (EM_rain .eq. "tmatr")) stop "1moment tmatr not tested yet for rain"

  call ref_water(0.d0, t-273.15, f, refre, refim, absind, abscof)
  mindex = refre-im*refim

  den_liq = 1.d3  ! density of liquid water [kg/m^3]

!  nbins = 100
  nbins = 50
!  dia1 = 1.d-10 ! minimum diameter [m]
!  dia2 = 6.d-3  ! maximum diameter [m]
  dia1 = 1.2d-4 ! minimum diameter [m]
  dia2 = 6.d-3  ! maximum diameter [m]

  if (n_moments .eq. 1) then

	if (SD_rain .eq. 'C') then

	  ! this is for integration over diameters

	  ad = n_0rainD*1.d6   ! [1/m^4]
   	  bd = (pi * den_liq * ad / rwc)**0.25
      alpha = 0.d0 ! exponential SD
      gamma = 1.d0
    else if (SD_rain .eq. 'M') then
      b_rain = 3.
      a_mrain = 524.
	  bd = (rwc/(a_mrain*1.d7*exp(gammln(b_rain+1.))))**(1./(-1.-b_rain))
	  ad = 1.d7
	  dia2 = log(ad)/bd
	  if (dia2 .gt. 6.d-3) dia2 = 6.d-3
      alpha = 0.d0 ! exponential SD
      gamma = 1.d0
    end if
  else if (n_moments .eq. 2) then
     if (nc .eq. 0.d0) stop 'STOP in routine rain_ssp'
     call double_moments(rwc,nc,gamma_rain(1),gamma_rain(2),gamma_rain(3),gamma_rain(4), &
          ad,bd,alpha,gamma,a_mrain, b_rain,cwc)
  else
     stop 'Number of moments is not specified'
  end if

  if (EM_rain .eq. "miera") then

    call mie(f, mindex, dia1, dia2, nbins, maxleg, ad,    &
	bd, alpha, gamma, lphase_flag, kext, salb, back,     &
	nlegen, legen, legen2, legen3, legen4, SD_rain,den_liq,rwc)
      scatter_matrix= 0.d0
      extinct_matrix= 0.d0
      emis_vector= 0.d0
  else if (EM_rain .eq. "tmatr") then
    if (use_rain_db) then
      call tmatrix_rain(f, rwc, t, nc, &
	    ad, bd, alpha, gamma, a_mrain, b_rain, SD_rain, scatter_matrix,extinct_matrix, emis_vector)
    else
      stop "tmatr without database not yet implemented yet"
    end if

    !back is for NOT polarized radiation only, if you want to simulate a polarized Radar, use the full scattering matrix!
    back = scatter_matrix(1,16,1,16,2) !scatter_matrix(A,B;C;D;E) backscattering is M11 of Mueller or Scattering Matrix (A;C=1), in quadrature 2 (E) first 16 (B) is 180deg (upwelling), 2nd 16 (D) 0deg (downwelling). this definition is lokkiing from BELOW, scatter_matrix(1,16,1,16,3) would be from above!
    back = 4*pi*back!/k**2 !eq 4.82 Bohren&Huffman without k**2 (because of different definition of Mueller matrix according to Mishenko AO 2000). note that scatter_matrix contains already squard entries!

    kext = extinct_matrix(1,1,16,1) !11 of extinction matrix (=not polarized), at 0°, first quadrature. equal to extinct_matrix(1,1,16,2)
     !not needed by rt4
    salb = 0.d0
    nlegen = 0
    legen = 0.0d0
    legen2 = 0.0d0
    legen3 = 0.0d0
    legen4 = 0.0d0
  else
    stop "unknown EM_rain"
  end if

  if (verbose .gt. 1) print*, 'Exiting rain_ssp'

  return

end subroutine rain_ssp
