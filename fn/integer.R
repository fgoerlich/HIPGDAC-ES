#   Script Name: integer.R
#   Description: Integer proportional redistribution
#   Created By:  Paco Goerlich.
#   Date:        20/05/2020
#   Last change: 13/01/2023


####################
#   proportional   #
####################
#   Description: Proportional redistribution.
#   Arguments:
#      v: vector.
#      t: total to adjust.
#   Value:
#      vector summing to t.
#   Details:
#      It scales proportionally the elements of v to sum t.
#      t should be strictly positive
#      v should be non-negative and at least one element should be postive: zeros are preserved
proportional <- function(v, t){
    stopifnot(t > 0 & min(v) >= 0 & sum(v) > 0)

    t*(v/sum(v))
}


#####################
#   iproportional   #
#####################
#   Description: Integer proportional redistribution --> integer version of proportional()
#   Arguments:
#      v: vector (non-negative and at least one element stricly postive: zeros are preserved).
#      t: total to adjust (integer and strictly positive).
#   Value:
#      vector of integers summing to t.
#   Details:
#      Rule for integer assignment 'controled rounding' of Cox (1987-JASA), as implemented in Balinski & Rachev (1997-MS, p.-5).
#      This is essentially the 'method of greatest remainders'.
#      After proportional() adjustment, truncate to integers and add 1 at a time to the maximum fractional of the remaining part.
#      In case of the maximum fractional is NOT unique the assignment is done to the first maximum encountered.
#      In this case, changing the order of the elements in v may change the final result slightly.
iproportional <- function(v, t){
    stopifnot(bazar::is.wholenumber(t))
    stopifnot(t > 0 & min(v) >= 0 & sum(v) > 0)

    real <- proportional(v, t)
    v    <- trunc(real)
    while(sum(v) < t){
        i <- which.max(real - v)
        v[i] <- v[i] + 1
    }
    return(v)
}
