#import <CoreGraphics/CGGeometry.h>
#import <math.h>

#ifdef __cplusplus
extern "C" {
#endif	

/** Helper macro that creates a CGPoint
 @return CGPoint
 @since v0.7.2
 */
#define ccp(__X__,__Y__) CGPointMake(__X__,__Y__)


/** Returns opposite of point.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpNeg(const CGPoint v)
{
	return ccp(-v.x, -v.y);
}

/** Calculates sum of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpAdd(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x + v2.x, v1.y + v2.y);
}

/** Calculates difference of two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpSub(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x - v2.x, v1.y - v2.y);
}

/** Returns point multiplied by given factor.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpMult(const CGPoint v, const CGFloat s)
{
	return ccp(v.x*s, v.y*s);
}

/** Calculates midpoint between two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpMidpoint(const CGPoint v1, const CGPoint v2)
{
	return ccpMult(ccpAdd(v1, v2), 0.5f);
}

/** Calculates dot product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpDot(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

/** Calculates cross product of two points.
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpCross(const CGPoint v1, const CGPoint v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpPerp(const CGPoint v)
{
	return ccp(-v.y, v.x);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpRPerp(const CGPoint v)
{
	return ccp(v.y, -v.x);
}

/** Calculates the projection of v1 over v2.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpProject(const CGPoint v1, const CGPoint v2)
{
	return ccpMult(v2, ccpDot(v1, v2)/ccpDot(v2, v2));
}

/** Rotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpRotate(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

/** Unrotates two points.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
ccpUnrotate(const CGPoint v1, const CGPoint v2)
{
	return ccp(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

/** Calculates the square length of a CGPoint (not calling sqrt() )
 @return CGFloat
 @since v0.7.2
 */
static inline CGFloat
ccpLengthSQ(const CGPoint v)
{
	return ccpDot(v, v);
}

/** Calculates distance between point an origin
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpLength(const CGPoint v);

/** Calculates the distance between two points
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpDistance(const CGPoint v1, const CGPoint v2);

/** Returns point multiplied to a length of 1.
 @return CGPoint
 @since v0.7.2
 */
CGPoint ccpNormalize(const CGPoint v);

/** Converts radians to a normalized vector.
 @return CGPoint
 @since v0.7.2
 */
CGPoint ccpForAngle(const CGFloat a);

/** Converts a vector to radians.
 @return CGFloat
 @since v0.7.2
 */
CGFloat ccpToAngle(const CGPoint v);

#ifdef __cplusplus
}
#endif
