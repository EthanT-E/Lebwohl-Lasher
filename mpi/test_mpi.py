import pytest
from Leb_mpi import one_energy
import numpy as np


@pytest.mark.parametrize("x,y,expected", [
    (1, 1, -4),
    (0, 1, -2.9378898725896434),
    (3, 1, -4),
    (0, 0, -2.9378898725896434),
    (3, 0, -4)
])
def test_one_energy(x, y, expected):
    matrix = np.ones((8, 4))
    left_col = np.zeros(8)
    right_col = np.ones(8)
    assert one_energy(matrix, x, y, 8, 4, left_col, right_col) == expected
