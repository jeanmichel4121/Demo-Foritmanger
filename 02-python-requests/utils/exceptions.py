"""
Custom exceptions for FortiManager API
"""


class FMGError(Exception):
    """Base FortiManager error."""

    def __init__(self, message: str, code: int = -1):
        self.message = message
        self.code = code
        super().__init__(f"[{code}] {message}")


class FMGAuthError(FMGError):
    """Authentication error."""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message, code=-11)


class FMGRequestError(FMGError):
    """API request error."""

    pass


class FMGObjectNotFoundError(FMGError):
    """Object not found."""

    def __init__(self, object_name: str):
        super().__init__(f"Object '{object_name}' not found", code=-2)


class FMGObjectExistsError(FMGError):
    """Object already exists."""

    def __init__(self, object_name: str):
        super().__init__(f"Object '{object_name}' already exists", code=-3)


class FMGPermissionError(FMGError):
    """Permission denied."""

    def __init__(self, message: str = "Permission denied"):
        super().__init__(message, code=-6)
