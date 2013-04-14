#include "stdio.h"
#include "math.h"

#include "CGPointExtension.h"

CGFloat
ccpLength(const CGPoint v)
{
	return sqrtf(ccpLengthSQ(v));
}

CGFloat
ccpDistance(const CGPoint v1, const CGPoint v2)
{
	return ccpLength(ccpSub(v1, v2));
}

CGPoint
ccpNormalize(const CGPoint v)
{
	return ccpMult(v, 1.0f/ccpLength(v));
}

CGPoint
ccpForAngle(const CGFloat a)
{
	return ccp(cosf(a), sinf(a));
}

CGFloat
ccpToAngle(const CGPoint v)
{
	return atan2f(v.y, v.x);
}
