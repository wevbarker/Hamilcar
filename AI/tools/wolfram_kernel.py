"""
Wolfram Kernel Manager

Maintains a persistent Wolfram kernel session for Hamilcar computations.
"""

import logging
from typing import Optional
from wolframclient.evaluation import WolframLanguageSession
from wolframclient.language import wl, wlexpr

logger = logging.getLogger(__name__)


class WolframKernelManager:
    """Manages a persistent Wolfram kernel session."""

    def __init__(self, kernel_path: Optional[str] = None):
        """
        Initialize the Wolfram kernel manager.

        Args:
            kernel_path: Path to Wolfram kernel executable.
                        If None, uses default system path.
        """
        self.kernel_path = kernel_path or "wolframkernel"
        self.session: Optional[WolframLanguageSession] = None
        self._hamilcar_loaded = False

    def start(self) -> None:
        """Start the Wolfram kernel session."""
        if self.session is not None:
            logger.warning("Kernel already running")
            return

        logger.info(f"Starting Wolfram kernel: {self.kernel_path}")
        self.session = WolframLanguageSession(self.kernel_path)
        logger.info("Wolfram kernel started successfully")

    def stop(self) -> None:
        """Stop the Wolfram kernel session."""
        if self.session is None:
            logger.warning("No kernel to stop")
            return

        logger.info("Stopping Wolfram kernel")
        self.session.terminate()
        self.session = None
        self._hamilcar_loaded = False
        logger.info("Wolfram kernel stopped")

    def restart(self) -> None:
        """Restart the Wolfram kernel session."""
        logger.info("Restarting Wolfram kernel")
        self.stop()
        self.start()
        if self._hamilcar_loaded:
            self.load_hamilcar()

    def load_hamilcar(self) -> bool:
        """
        Load the Hamilcar package into the kernel.

        Returns:
            True if successful, False otherwise.
        """
        if self.session is None:
            raise RuntimeError("Kernel not started")

        try:
            logger.info("Loading Hamilcar package")
            result = self.session.evaluate(wlexpr('<<xAct`Hamilcar`'))
            self._hamilcar_loaded = True
            logger.info("Hamilcar package loaded successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to load Hamilcar: {e}")
            return False

    def evaluate(self, code: str, load_hamilcar: bool = True) -> any:
        """
        Evaluate Wolfram Language code.

        Args:
            code: Wolfram Language code to evaluate
            load_hamilcar: If True, ensure Hamilcar is loaded first

        Returns:
            Result of the evaluation
        """
        if self.session is None:
            raise RuntimeError("Kernel not started. Call start() first.")

        if load_hamilcar and not self._hamilcar_loaded:
            self.load_hamilcar()

        logger.debug(f"Evaluating: {code}")
        result = self.session.evaluate(wlexpr(code))
        logger.debug(f"Result: {result}")
        return result

    def evaluate_function(self, func_name: str, *args, load_hamilcar: bool = True) -> any:
        """
        Evaluate a Hamilcar function with arguments.

        Args:
            func_name: Name of the Hamilcar function
            *args: Arguments to pass to the function
            load_hamilcar: If True, ensure Hamilcar is loaded first

        Returns:
            Result of the function evaluation
        """
        if self.session is None:
            raise RuntimeError("Kernel not started. Call start() first.")

        if load_hamilcar and not self._hamilcar_loaded:
            self.load_hamilcar()

        logger.debug(f"Calling {func_name} with args: {args}")
        # Build function call using wolframclient's expression builder
        func = getattr(wl, func_name)
        result = self.session.evaluate(func(*args))
        logger.debug(f"Result: {result}")
        return result

    def is_running(self) -> bool:
        """Check if kernel is running."""
        return self.session is not None

    def __enter__(self):
        """Context manager entry."""
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.stop()
