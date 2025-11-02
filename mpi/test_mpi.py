import pytest
from Leb_mpi import one_energy, all_energy, get_order, initdat
import numpy as np


@pytest.mark.parametrize("x,y,expected", [
    (1, 1, -4),
    (0, 1, pytest.approx(-3.985, abs=1e-4)),
    (3, 1, pytest.approx(-3.0796, abs=1e-4)),
    (0, 0, pytest.approx(-3.985, abs=1e-4)),
    (3, 0, pytest.approx(-3.0796, abs=1e-4))
])
def test_one_energy(x, y, expected):
    matrix = np.full((8, 4), 0.1)
    left_col = np.zeros(8)
    right_col = np.ones(8)
    assert one_energy(matrix, x, y, 8, 4, left_col, right_col) == expected


# def test_all_energy():
#     matrix = np.ones((8, 4))
#     left_col = np.zeros(8)
#     right_col = np.ones(8)
#     assert all_energy(matrix, 8, 4, left_col,
#                       right_col) == pytest.approx(-120.5168, abs=1e-4)


# @pytest.mark.parametrize("lattice, nmax,task_width,expected", [
#     (initdat(8, 2), 8, 4, pytest.approx(0.25, abs=1e-1)),
#     (np.ones((8, 4)), 8, 4, pytest.approx(1))
# ])
# def test_get_order(lattice, nmax, task_width, expected):
#     assert get_order(lattice, nmax, task_width) == expected
