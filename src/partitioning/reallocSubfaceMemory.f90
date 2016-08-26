       subroutine reallocSubfaceMemory(ii,nAlloc)
!
!       reallocSubfaceMemory reallocates the memory to store the       
!       subface information for the given block ii. On entry nAlloc    
!       contains the current number of allocated subfaces, on exit     
!       this is updated to the new number.                             
!
       use partitionMod
       use utils, only : reallocateInteger
       implicit none
!
!      Subroutine arguments.
!
       integer(kind=intType), intent(in)    :: ii
       integer(kind=intType), intent(inout) :: nAlloc
!
!      Local arguments.
!
       integer(kind=intType) :: nOld, nNew
!
       ! Store the old value of the allocated array and determine the
       ! new one. Store this new value in nAlloc.

       nOld   = nAlloc
       nNew   = nOld + 6
       nAlloc = nNew

       ! Reallocate the memory.

       call reallocateInteger(blocks(ii)%BCType,      nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%BCFaceID,    nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%cgnsSubface, nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%inBeg, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%jnBeg, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%knBeg, nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%inEnd, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%jnEnd, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%knEnd, nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%dinBeg, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%djnBeg, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%dknBeg, nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%dinEnd, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%djnEnd, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%dknEnd, nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%neighBlock, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%groupNum,   nNew, nOld, .true.)

       call reallocateInteger(blocks(ii)%l1, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%l2, nNew, nOld, .true.)
       call reallocateInteger(blocks(ii)%l3, nNew, nOld, .true.)
 
       end subroutine reallocSubfaceMemory
