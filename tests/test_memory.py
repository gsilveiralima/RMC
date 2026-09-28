import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import rmc_agent


class MemoryTest(unittest.TestCase):
    def test_load_missing_memory_is_empty(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "memory.txt"
            with patch.object(rmc_agent, "MEMORY_FILE", path):
                self.assertEqual(rmc_agent.load_memory(), "")

    def test_save_and_load_memory(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "memory.txt"
            with patch.object(rmc_agent, "MEMORY_FILE", path):
                rmc_agent.save_memory("Usuário: teste\nRMC: resposta")
                self.assertEqual(
                    rmc_agent.load_memory(),
                    "Usuário: teste\nRMC: resposta\n---\n",
                )

    def test_nist_integration_is_optional(self) -> None:
        result = rmc_agent.get_nist_control("RA-5")
        self.assertIsInstance(result, str)
        self.assertTrue(result)


if __name__ == "__main__":
    unittest.main()
