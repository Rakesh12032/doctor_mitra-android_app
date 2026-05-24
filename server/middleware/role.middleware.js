/**
 * Restricts route access to specific user roles.
 * Must be used AFTER protect middleware.
 * 
 * @param {...string} roles Roles allowed (e.g. 'patient', 'doctor', 'admin')
 */
exports.checkRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Role (${req.user ? req.user.role : 'guest'}) is not authorized to access this resource.`,
      });
    }
    next();
  };
};

// Alias for convenience
exports.authorizeRoles = exports.checkRole;
