import pytest
from run_cython import initdat
from Leb_cython import MC_step, all_energy, get_order, one_energy
import numpy as np


@pytest.mark.parametrize("size", [
    2, 50
])
def test_initdata(size):
    arr1 = initdat(size)
    arr2 = initdat(size)
    arr3 = initdat(size)
    not_equal = True
    if (arr1 == arr2) and (arr2 == arr3):
        not_equal = False
    assert not_equal == True, f"Init array is equal: {not_equal}"


@pytest.mark.parametrize("matrix, size, expected, err_message", [
    (np.ones((2, 2), dtype=np.float64), 2, -4, "expected -4"),
    (np.ones((3, 3), dtype=np.float64), 3, -4, "expected -4")
])
def test_one_energy(matrix, size, expected, err_message):
    assert one_energy(matrix, 0, 0, size) == expected, err_message


@pytest.mark.parametrize("matrix, size, expected", [
    (np.ones((2, 2), dtype=np.float64), 2, (-4*2*2)),
    (np.ones((3, 3), dtype=np.float64), 3, (-4*3*3))
])
def test_all_energy(matrix, size, expected):
    assert all_energy(matrix, size) == expected


@pytest.mark.parametrize("matrix,size,expected", [
    (np.ones((2, 2), dtype=np.float64), 2, 0.9999999999999999),
    (np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]],
     dtype=np.float64), 3, 0.29081329923849963)
])
def test_get_order(matrix, size, expected):
    assert get_order(matrix, size) == expected


@pytest.mark.parametrize("temp, size", [
    (0.1, 9),
    (0.1, 20),
    (2, 9),
    (2.0, 20),
    (1.6, 2),
])
def test_mc_step(temp, size):
    """
    Tests if the output is still random as all the ratios should be slightly different
    But it is good to consider for very small matrix size will likely produce duplicants
    """
    results = []
    for i in range(0, 5):  # Five as it is unlikely that all five runs will have the same ratio
        arr = np.ones((size, size), dtype=np.float64)
        output = MC_step(arr, temp, size)
        results.append(output)

    results = set(results)  # deletes repeats
    assert len(results) != 1
