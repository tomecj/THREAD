program example

	use solver
	use mesher
	use mesh_object
	
	implicit none
	
	character (len=100)							:: LineIn = ''
	character (len=10)							:: string = ''
	integer										:: lenLineIn, startValue, endValue
	double precision							:: length, moment, nel_d
	
	integer										:: Nele, Nno, order, Ngauss
	type (ElementMesh) 							:: mesh
	double precision, allocatable 				:: X (:,:), U (:,:)
	double precision, dimension (6, 6)			:: C
	logical, allocatable						:: DOF (:,:)
	double precision, allocatable				:: dU (:,:), Q (:,:)
	double precision, allocatable				:: p (:,:,:), f (:,:,:)
	double precision, allocatable				:: om (:,:,:)
	double precision, allocatable				:: rot (:,:,:,:)
	double precision, allocatable				:: R (:,:)
	double precision, dimension (6), parameter	:: material = (/ 1.0D0, 1.0D0, 1.0D0, 1.0D0, 2.0D0, 1.0D0 /)
	integer, parameter							:: MAXITER = 20
	double precision, parameter					:: TOLER = 1D-5
	integer										:: i, j, Niter, info
	character (len=5), dimension (3)			:: labels
	character (len=10), dimension (2)			:: input_labels
	double precision, dimension (2)				:: input_data
	
	! Determine the length of the data string
    ! that is to be read in the next section.
	call Get_Environment_Variable('CONTENT_LENGTH', string)
	read (string, *) lenLineIn

	! Read the data from the html form into the
	! variable LineIn, a single character at a time.
	do i = 1, lenLineIn
		read (*, ADVANCE='NO', FMT='(A)') LineIn(i:i)
	end do
	
	! Locate and read the value of 'length' from LineIn (name in html form)
	startValue = index (LineIn, 'length=') + 7
	endValue = startValue + index(LineIn(startValue:), '&') - 2
	read (LineIn(startValue:endValue), *) length

	! Locate and read the value of 'moment' from LineIn (name in html form)
	startValue = index (LineIn, 'moment=') + 7
	endValue = startValue + index(LineIn(startValue:), '&') - 2
	read (LineIn(startValue:endValue), *) moment
	
	! Locate and read the value of 'nel' from LineIn
	startValue = index(LineIn,'nel=') + 4
	read (LineIn(startValue:), *) nel_d
	
	! Send a header to the browser, identifying
	! the type of information that will be sent.
	write (*, '("Content-type: text/html",//)')
	
	! Begin with html
	write (*, *) '<html><body>'
	
	! =================================================
	! MESH
	Nele = int (nel_d)
	order = 1
	Ngauss = order
	Nno = Nele * order + 1
	
	allocate (X (3, Nno), U (3, Nno), DOF (6, Nno), dU (6, Nno), Q (6, Nno))
	allocate (p (Nele, 6, Ngauss), f (Nele, 6, Ngauss), om (Nele, 3, Ngauss))
	allocate (rot (Nele, Ngauss, 3, 3), R (6, Nno))
		
	mesh%Nno = Nno
	mesh%Nele = Nele
	mesh%order = 1
	call lmsh (length, mesh)
	do i = 1, Nele
		do j = 1, Ngauss
			rot (i, j, 1, :)= (/ 1.0D0, 0.0D0, 0.0D0 /)
			rot (i, j, 2, :)= (/ 0.0D0, 1.0D0, 0.0D0 /)
			rot (i, j, 3, :)= (/ 0.0D0, 0.0D0, 1.0D0 /)
		end do
	end do
	
	! =================================================
	! ELASTIC MODULI MATRIX
	C = 0.0D0  ! add material
	do i = 1, 6
		C (i, i) = material (i)
	end do
	
	
	! =================================================
	! DATA INITIALIZATION
	U = 0.0D0
	p = 0.0D0
	f = 0.0D0
	om = 0.0D0
	
	! =================================================
	! BOUNDARY CONDITIONS
	DOF = .TRUE.
	DOF (:, 1) = .FALSE.
	dU = 0.0D0
	Q = 0.0D0
	
	! =================================================
	! FORCE CONTROL ROUTINE
	do j = 0, 10
		if (j > 0) then
			Q (5, Nno) = Q (5, Nno) + moment / 10
			call newton_iter (mesh%ele, mesh%X0, U, C, DOF, dU, Q, p, rot, om, f, R, TOLER, MAXITER, 'RSD', Niter, info, .FALSE.)
		end if
		
		X (1, :) = mesh%X0 (1, :) + U (1, :)
		X (2, :) = mesh%X0 (2, :) + U (2, :)
		X (3, :) = mesh%X0 (3, :) + U (3, :)
				
	end do
		
	! =================================================
	! HTML OUTPUT
	
	write (*, *) '<p>Success!</p>'

	input_labels (1) = 'Length'
	input_data (1) = length
	input_labels (2) = 'No elem'
	input_data (2) = Nele
	call htmlinput (input_labels, input_data, 2)
	
	labels (1) = 'x'
	labels (2) = 'y'
	labels (3) = 'z'
	call htmlmatrix (X, labels, 3, Nno)
	write (*, *) '</body></html>'

	call htmlplot (X (1,:), X (3,:), Nno)
	
end program example

subroutine htmlmatrix (A, b, ndim, n)
		
	implicit none
	
	double precision, dimension (ndim,n), intent(in) 	:: A
	character (len=5), dimension (ndim), intent(in)		:: b
	integer 											:: i, j, ndim, n
	character (len = 140)								:: arrayfmt
	character (len = 30)								:: numfmt
	
	write (*,*) '<table style="width:33%">'
	do i = 0, n
		if (i.eq.0) then
			write (arrayfmt, '("<tr><th>", A, "</th>")') 'i'
			do j = 1, ndim	
				write (numfmt,'("<th>", A, "</th>")') b (j)
				arrayfmt = trim (arrayfmt) // trim (numfmt)
			end do
			arrayfmt = arrayfmt//'</tr>'
			write (*,*) arrayfmt
		else
			write (arrayfmt, '("<tr><th>", i3, "</th>")') i
			do j = 1, ndim	
				write (numfmt,'("<th>", f10.3, "</th>")') A (j, i)
				arrayfmt = trim (arrayfmt) // trim (numfmt)
			end do
			arrayfmt = arrayfmt//'</tr>'
			write (*,*) arrayfmt
		end if
	end do	
	write (*,*) '</table>'
	
end subroutine htmlmatrix

subroutine htmlinput (names, data, n)
		
	implicit none
	
	double precision, dimension (n), intent(in) 		:: data
	character (len=10), dimension (n), intent(in)		:: names
	integer 											:: i, j, ndim, n
	character (len = 140)								:: arrayfmt
	character (len = 30)								:: numfmt

	write (*,*) '<table style="width:33%">'
	do i = 0,1
		if (i.eq.0) then
			write (arrayfmt, '("<tr>")')
			do j = 1, n
				write (numfmt,'("<th>", A, "</th>")') names (j)
				arrayfmt = trim (arrayfmt) // trim (numfmt)
			end do
			arrayfmt = arrayfmt//'</tr>'
			write (*,*) arrayfmt
		else
			write (arrayfmt, '("<tr>")')
			do j = 1, n
				write (numfmt,'("<th>", f10.3, "</th>")') data (j)
				arrayfmt = trim (arrayfmt) // trim (numfmt)
			end do
			arrayfmt = arrayfmt//'</tr>'
			write (*,*) arrayfmt
		end if
	end do	
	write (*,*) '</table>'
	
end subroutine htmlinput

subroutine htmlplot (x, y, n)

	implicit none

	integer												:: n, i, w, h
	double precision, dimension (n), intent(in) 		:: x, y
	double precision, dimension (n)						:: u, v
	double precision									:: minx, miny, maxx, maxy, dx, dy, d

	! Set plot pixel width and height
	w = 400
	h = 400

	! Compute points locations
	minx = minval (x)
	maxx = maxval (x)
	miny = minval (y)
	maxy = maxval (y)
	dx = maxx - minx
	dy = maxy - miny

	d = max (dx, dy)
	d = 1.2 * d

	do i = 1, n
		u (i) = (x (i) - minx) / d * w + 0.1*w
		v (i) = h - (y (i) - miny) / d * h - 0.1*h
	end do


	! Create canvas
	
	write (*,*) '<canvas id="myCanvas"'
	write (*, '(4X, A, I3, A, I3, A)') 'width="', w, '" height="', h, '" style="border:1px solid #000000;">'
	write (*,*) '</canvas>'

	! Draw points
	write (*,*) '<script>'
	write (*,*) 'var canvas = document.getElementById("myCanvas");'
	write (*,*) 'var ctx = canvas.getContext("2d");'
	write (*,*) 'ctx.fillStyle = "green";'
	do i = 1, n
		write (*,*) 'ctx.beginPath();'
		if (i.lt.n) then
			write (*, '("ctx.moveTo(", f5.1, ", ", f5.1, ");")') u (i), v (i)
			write (*, '("ctx.lineTo(", f5.1, ", ", f5.1, ");")') u (i+1), v (i+1)
			write (*,*) 'ctx.stroke();'
		end if
	end do
    do i = 1, n
		write (*,*) 'ctx.beginPath();'
		write (*,'("ctx.arc(", f5.1, ", ", f5.1, ", 4, 0, 2 * Math.PI);")') u (i), v (i)
		write (*,*) 'ctx.fill();'
	end do
	write (*,*) '</script>'

end subroutine htmlplot
