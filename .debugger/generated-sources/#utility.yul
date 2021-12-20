{
    { }
    function validator_revert_bytes4(value)
    {
        if iszero(eq(value, and(value, shl(224, 0xffffffff)))) { revert(0, 0) }
    }
    function abi_decode_tuple_t_bytes4(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_bytes4(value)
        value0 := value
    }
    function abi_encode_tuple_t_bool__to_t_bool__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, iszero(iszero(value0)))
    }
    function copy_memory_to_memory(src, dst, length)
    {
        let i := 0
        for { } lt(i, length) { i := add(i, 32) }
        {
            mstore(add(dst, i), mload(add(src, i)))
        }
        if gt(i, length) { mstore(add(dst, length), 0) }
    }
    function abi_encode_string(value, pos) -> end
    {
        let length := mload(value)
        mstore(pos, length)
        copy_memory_to_memory(add(value, 0x20), add(pos, 0x20), length)
        end := add(add(pos, and(add(length, 31), not(31))), 0x20)
    }
    function abi_encode_tuple_t_string_memory_ptr__to_t_string_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        mstore(headStart, 32)
        tail := abi_encode_string(value0, add(headStart, 32))
    }
    function abi_decode_tuple_t_uint256(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        value0 := calldataload(headStart)
    }
    function abi_encode_tuple_t_address__to_t_address__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
    }
    function validator_revert_address(value)
    {
        if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
    }
    function abi_decode_tuple_t_addresst_uint256(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        value1 := calldataload(add(headStart, 32))
    }
    function abi_decode_tuple_t_address(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
    }
    function abi_encode_tuple_t_array$_t_uint256_$dyn_memory_ptr__to_t_array$_t_uint256_$dyn_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        let _1 := 32
        let tail_1 := add(headStart, _1)
        mstore(headStart, _1)
        let pos := tail_1
        let length := mload(value0)
        mstore(tail_1, length)
        pos := add(headStart, 64)
        let srcPtr := add(value0, _1)
        let i := 0
        for { } lt(i, length) { i := add(i, 1) }
        {
            mstore(pos, mload(srcPtr))
            pos := add(pos, _1)
            srcPtr := add(srcPtr, _1)
        }
        tail := pos
    }
    function abi_encode_tuple_t_uint256__to_t_uint256__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, value0)
    }
    function abi_decode_tuple_t_addresst_addresst_uint256(headStart, dataEnd) -> value0, value1, value2
    {
        if slt(sub(dataEnd, headStart), 96) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_address(value_1)
        value1 := value_1
        value2 := calldataload(add(headStart, 64))
    }
    function validator_revert_bool(value)
    {
        if iszero(eq(value, iszero(iszero(value)))) { revert(0, 0) }
    }
    function abi_decode_tuple_t_uint256t_addresst_uint256t_boolt_uint256(headStart, dataEnd) -> value0, value1, value2, value3, value4
    {
        if slt(sub(dataEnd, headStart), 160) { revert(0, 0) }
        value0 := calldataload(headStart)
        let value := calldataload(add(headStart, 32))
        validator_revert_address(value)
        value1 := value
        value2 := calldataload(add(headStart, 64))
        let value_1 := calldataload(add(headStart, 96))
        validator_revert_bool(value_1)
        value3 := value_1
        value4 := calldataload(add(headStart, 128))
    }
    function abi_decode_tuple_t_uint256t_uint256t_boolt_uint256(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        value0 := calldataload(headStart)
        value1 := calldataload(add(headStart, 32))
        let value := calldataload(add(headStart, 64))
        validator_revert_bool(value)
        value2 := value
        value3 := calldataload(add(headStart, 96))
    }
    function panic_error_0x41()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x41)
        revert(0, 0x24)
    }
    function finalize_allocation_6035(memPtr)
    {
        let newFreePtr := add(memPtr, 0x60)
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
    }
    function finalize_allocation(memPtr, size)
    {
        let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
    }
    function allocate_memory() -> memPtr
    {
        memPtr := mload(64)
        let newFreePtr := add(memPtr, 0xc0)
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
    }
    function abi_decode_uint64(offset) -> value
    {
        value := calldataload(offset)
        if iszero(eq(value, and(value, 0xffffffffffffffff))) { revert(0, 0) }
    }
    function abi_decode_struct_CommissionData(headStart, end) -> value
    {
        if slt(sub(end, headStart), 0x40) { revert(0, 0) }
        let memPtr := mload(0x40)
        let newFreePtr := add(memPtr, 0x40)
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(0x40, newFreePtr)
        value := memPtr
        mstore(memPtr, abi_decode_uint64(headStart))
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_address(value_1)
        mstore(add(memPtr, 32), value_1)
    }
    function abi_decode_tuple_t_struct$_CommissionInfo_$1605_memory_ptr(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        let memPtr := mload(64)
        finalize_allocation_6035(memPtr)
        mstore(memPtr, abi_decode_uint64(headStart))
        mstore(add(memPtr, 32), abi_decode_uint64(add(headStart, 32)))
        mstore(add(memPtr, 64), abi_decode_struct_CommissionData(add(headStart, 64), dataEnd))
        value0 := memPtr
    }
    function abi_encode_struct_CommissionData(value, pos)
    {
        mstore(pos, and(mload(value), 0xffffffffffffffff))
        mstore(add(pos, 0x20), and(mload(add(value, 0x20)), sub(shl(160, 1), 1)))
    }
    function abi_encode_tuple_t_uint64_t_uint64_t_struct$_CommissionData_$1610_memory_ptr__to_t_uint64_t_uint64_t_struct$_CommissionData_$1610_memory_ptr__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 128)
        let _1 := 0xffffffffffffffff
        mstore(headStart, and(value0, _1))
        mstore(add(headStart, 32), and(value1, _1))
        abi_encode_struct_CommissionData(value2, add(headStart, 64))
    }
    function abi_encode_tuple_t_uint64_t_address_t_uint256__to_t_uint64_t_address_t_uint256__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        mstore(headStart, and(value0, 0xffffffffffffffff))
        mstore(add(headStart, 32), and(value1, sub(shl(160, 1), 1)))
        mstore(add(headStart, 64), value2)
    }
    function abi_decode_available_length_string(src, length, end) -> array
    {
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }
        let memPtr := mload(64)
        finalize_allocation(memPtr, add(and(add(length, 31), not(31)), 0x20))
        array := memPtr
        mstore(memPtr, length)
        if gt(add(src, length), end) { revert(0, 0) }
        calldatacopy(add(memPtr, 0x20), src, length)
        mstore(add(add(memPtr, length), 0x20), 0)
    }
    function abi_decode_string(offset, end) -> array
    {
        if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
        array := abi_decode_available_length_string(add(offset, 0x20), calldataload(offset), end)
    }
    function abi_decode_tuple_t_string_memory_ptrt_string_memory_ptr(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let offset := calldataload(headStart)
        let _1 := 0xffffffffffffffff
        if gt(offset, _1) { revert(0, 0) }
        value0 := abi_decode_string(add(headStart, offset), dataEnd)
        let offset_1 := calldataload(add(headStart, 32))
        if gt(offset_1, _1) { revert(0, 0) }
        value1 := abi_decode_string(add(headStart, offset_1), dataEnd)
    }
    function abi_decode_tuple_t_string_memory_ptrt_string_memory_ptrt_string_memory_ptrt_address(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        let offset := calldataload(headStart)
        let _1 := 0xffffffffffffffff
        if gt(offset, _1) { revert(0, 0) }
        value0 := abi_decode_string(add(headStart, offset), dataEnd)
        let offset_1 := calldataload(add(headStart, 32))
        if gt(offset_1, _1) { revert(0, 0) }
        value1 := abi_decode_string(add(headStart, offset_1), dataEnd)
        let offset_2 := calldataload(add(headStart, 64))
        if gt(offset_2, _1) { revert(0, 0) }
        value2 := abi_decode_string(add(headStart, offset_2), dataEnd)
        let value := calldataload(add(headStart, 96))
        validator_revert_address(value)
        value3 := value
    }
    function abi_decode_address_payable(offset) -> value
    {
        value := calldataload(offset)
        validator_revert_address(value)
    }
    function abi_decode_uint32(offset) -> value
    {
        value := calldataload(offset)
        if iszero(eq(value, and(value, 0xffffffff))) { revert(0, 0) }
    }
    function abi_decode_struct_SaleInfo(headStart, end) -> value
    {
        if slt(sub(end, headStart), 0x60) { revert(0, 0) }
        let memPtr := mload(64)
        finalize_allocation_6035(memPtr)
        value := memPtr
        mstore(memPtr, abi_decode_uint64(headStart))
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_address(value_1)
        mstore(add(memPtr, 32), value_1)
        mstore(add(memPtr, 64), calldataload(add(headStart, 64)))
    }
    function abi_decode_tuple_t_uint64t_struct$_SeriesInfo_$1597_memory_ptr(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := abi_decode_uint64(headStart)
        let offset := calldataload(add(headStart, 32))
        let _1 := 0xffffffffffffffff
        if gt(offset, _1) { revert(0, 0) }
        let _2 := add(headStart, offset)
        if slt(sub(dataEnd, _2), 0x0120) { revert(0, 0) }
        let value := allocate_memory()
        mstore(value, abi_decode_address_payable(_2))
        mstore(add(value, 32), abi_decode_uint32(add(_2, 32)))
        mstore(add(value, 64), abi_decode_struct_SaleInfo(add(_2, 64), dataEnd))
        mstore(add(value, 0x60), abi_decode_struct_CommissionData(add(_2, 160), dataEnd))
        let offset_1 := calldataload(add(_2, 224))
        if gt(offset_1, _1) { revert(0, 0) }
        mstore(add(value, 0x80), abi_decode_string(add(_2, offset_1), dataEnd))
        let offset_2 := calldataload(add(_2, 256))
        if gt(offset_2, _1) { revert(0, 0) }
        mstore(add(value, 160), abi_decode_string(add(_2, offset_2), dataEnd))
        value1 := value
    }
    function abi_encode_struct_SaleInfo(value, pos)
    {
        mstore(pos, and(mload(value), 0xffffffffffffffff))
        mstore(add(pos, 0x20), and(mload(add(value, 0x20)), sub(shl(160, 1), 1)))
        mstore(add(pos, 0x40), mload(add(value, 0x40)))
    }
    function abi_encode_tuple_t_struct$_SaleInfo_$1582_memory_ptr__to_t_struct$_SaleInfo_$1582_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 96)
        abi_encode_struct_SaleInfo(value0, headStart)
    }
    function abi_decode_tuple_t_uint64(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        value0 := abi_decode_uint64(headStart)
    }
    function array_allocation_size_array_uint256_dyn(length) -> size
    {
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }
        size := add(shl(5, length), 0x20)
    }
    function abi_decode_array_address_dyn(offset, end) -> array
    {
        if iszero(slt(add(offset, 0x1f), end)) { revert(0, 0) }
        let _1 := calldataload(offset)
        let _2 := 0x20
        let _3 := array_allocation_size_array_uint256_dyn(_1)
        let memPtr := mload(64)
        finalize_allocation(memPtr, _3)
        let dst := memPtr
        mstore(memPtr, _1)
        dst := add(memPtr, _2)
        let srcEnd := add(add(offset, shl(5, _1)), _2)
        if gt(srcEnd, end) { revert(0, 0) }
        let src := add(offset, _2)
        for { } lt(src, srcEnd) { src := add(src, _2) }
        {
            let value := calldataload(src)
            validator_revert_address(value)
            mstore(dst, value)
            dst := add(dst, _2)
        }
        array := memPtr
    }
    function abi_decode_tuple_t_array$_t_uint256_$dyn_memory_ptrt_array$_t_address_$dyn_memory_ptr(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let offset := calldataload(headStart)
        let _1 := 0xffffffffffffffff
        if gt(offset, _1) { revert(0, 0) }
        let _2 := add(headStart, offset)
        if iszero(slt(add(_2, 0x1f), dataEnd)) { revert(0, 0) }
        let _3 := calldataload(_2)
        let _4 := 0x20
        let _5 := array_allocation_size_array_uint256_dyn(_3)
        let memPtr := mload(64)
        finalize_allocation(memPtr, _5)
        let dst := memPtr
        mstore(memPtr, _3)
        dst := add(memPtr, _4)
        let srcEnd := add(add(_2, shl(5, _3)), _4)
        if gt(srcEnd, dataEnd) { revert(0, 0) }
        let src := add(_2, _4)
        for { } lt(src, srcEnd) { src := add(src, _4) }
        {
            mstore(dst, calldataload(src))
            dst := add(dst, _4)
        }
        value0 := memPtr
        let offset_1 := calldataload(add(headStart, _4))
        if gt(offset_1, _1) { revert(0, 0) }
        value1 := abi_decode_array_address_dyn(add(headStart, offset_1), dataEnd)
    }
    function abi_decode_tuple_t_string_memory_ptr(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let offset := calldataload(headStart)
        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
        value0 := abi_decode_string(add(headStart, offset), dataEnd)
    }
    function abi_encode_tuple_t_array$_t_address_$dyn_memory_ptr__to_t_array$_t_address_$dyn_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        let _1 := 32
        let tail_1 := add(headStart, _1)
        mstore(headStart, _1)
        let pos := tail_1
        let length := mload(value0)
        mstore(tail_1, length)
        pos := add(headStart, 64)
        let srcPtr := add(value0, _1)
        let i := 0
        for { } lt(i, length) { i := add(i, 1) }
        {
            mstore(pos, and(mload(srcPtr), sub(shl(160, 1), 1)))
            pos := add(pos, _1)
            srcPtr := add(srcPtr, _1)
        }
        tail := pos
    }
    function abi_decode_tuple_t_addresst_bool(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_bool(value_1)
        value1 := value_1
    }
    function abi_decode_tuple_t_uint256t_address(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := calldataload(headStart)
        let value := calldataload(add(headStart, 32))
        validator_revert_address(value)
        value1 := value
    }
    function abi_decode_tuple_t_uint256t_uint256t_addresst_uint64(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        value0 := calldataload(headStart)
        value1 := calldataload(add(headStart, 32))
        let value := calldataload(add(headStart, 64))
        validator_revert_address(value)
        value2 := value
        value3 := abi_decode_uint64(add(headStart, 96))
    }
    function abi_decode_tuple_t_addresst_uint32(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        value1 := abi_decode_uint32(add(headStart, 32))
    }
    function abi_decode_tuple_t_addresst_addresst_uint256t_bytes_memory_ptr(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_address(value_1)
        value1 := value_1
        value2 := calldataload(add(headStart, 64))
        let offset := calldataload(add(headStart, 96))
        if gt(offset, 0xffffffffffffffff) { revert(0, 0) }
        let _1 := add(headStart, offset)
        if iszero(slt(add(_1, 0x1f), dataEnd)) { revert(0, 0) }
        value3 := abi_decode_available_length_string(add(_1, 32), calldataload(_1), dataEnd)
    }
    function abi_decode_tuple_t_uint256t_addresst_uint256t_bool(headStart, dataEnd) -> value0, value1, value2, value3
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        value0 := calldataload(headStart)
        let value := calldataload(add(headStart, 32))
        validator_revert_address(value)
        value1 := value
        value2 := calldataload(add(headStart, 64))
        let value_1 := calldataload(add(headStart, 96))
        validator_revert_bool(value_1)
        value3 := value_1
    }
    function abi_decode_tuple_t_uint256t_uint256t_bool(headStart, dataEnd) -> value0, value1, value2
    {
        if slt(sub(dataEnd, headStart), 96) { revert(0, 0) }
        value0 := calldataload(headStart)
        value1 := calldataload(add(headStart, 32))
        let value := calldataload(add(headStart, 64))
        validator_revert_bool(value)
        value2 := value
    }
    function abi_decode_tuple_t_uint64t_struct$_CommissionData_$1610_memory_ptr(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 96) { revert(0, 0) }
        value0 := abi_decode_uint64(headStart)
        value1 := abi_decode_struct_CommissionData(add(headStart, 32), dataEnd)
    }
    function abi_decode_tuple_t_addresst_address(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        let value := calldataload(headStart)
        validator_revert_address(value)
        value0 := value
        let value_1 := calldataload(add(headStart, 32))
        validator_revert_address(value_1)
        value1 := value_1
    }
    function abi_encode_tuple_t_struct$_SeriesInfo_$1597_memory_ptr__to_t_struct$_SeriesInfo_$1597_memory_ptr__fromStack_reversed(headStart, value0) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), and(mload(value0), sub(shl(160, 1), 1)))
        mstore(add(headStart, 64), and(mload(add(value0, 32)), 0xffffffff))
        let memberValue0 := mload(add(value0, 64))
        abi_encode_struct_SaleInfo(memberValue0, add(headStart, 96))
        let memberValue0_1 := mload(add(value0, 96))
        abi_encode_struct_CommissionData(memberValue0_1, add(headStart, 192))
        let memberValue0_2 := mload(add(value0, 0x80))
        let _1 := 0x0120
        mstore(add(headStart, 256), _1)
        let tail_1 := abi_encode_string(memberValue0_2, add(headStart, 320))
        let memberValue0_3 := mload(add(value0, 0xa0))
        mstore(add(headStart, _1), add(sub(tail_1, headStart), not(31)))
        tail := abi_encode_string(memberValue0_3, tail_1)
    }
    function abi_encode_tuple_t_address_payable_t_uint32_t_struct$_SaleInfo_$1582_memory_ptr_t_struct$_CommissionData_$1610_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__to_t_address_payable_t_uint32_t_struct$_SaleInfo_$1582_memory_ptr_t_struct$_CommissionData_$1610_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__fromStack_reversed(headStart, value5, value4, value3, value2, value1, value0) -> tail
    {
        let _1 := 288
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
        mstore(add(headStart, 32), and(value1, 0xffffffff))
        abi_encode_struct_SaleInfo(value2, add(headStart, 64))
        abi_encode_struct_CommissionData(value3, add(headStart, 160))
        mstore(add(headStart, 224), _1)
        let tail_1 := abi_encode_string(value4, add(headStart, _1))
        mstore(add(headStart, 256), sub(tail_1, headStart))
        tail := abi_encode_string(value5, tail_1)
    }
    function abi_decode_tuple_t_uint256t_struct$_SaleInfo_$1582_memory_ptr(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 128) { revert(0, 0) }
        value0 := calldataload(headStart)
        value1 := abi_decode_struct_SaleInfo(add(headStart, 32), dataEnd)
    }
    function extract_byte_array_length(data) -> length
    {
        length := shr(1, data)
        let outOfPlaceEncoding := and(data, 1)
        if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
        if eq(outOfPlaceEncoding, lt(length, 32))
        {
            mstore(0, shl(224, 0x4e487b71))
            mstore(4, 0x22)
            revert(0, 0x24)
        }
    }
    function abi_encode_tuple_t_stringliteral_9291e0f44949204f2e9b40e6be090924979d6047b2365868f4e9f027722eb89d__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 44)
        mstore(add(headStart, 64), "ERC721: approved query for nonex")
        mstore(add(headStart, 96), "istent token")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_b51b4875eede07862961e8f9365c6749f5fe55c6ee5d7a9e42b6912ad0b15942__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 33)
        mstore(add(headStart, 64), "ERC721: approval to current owne")
        mstore(add(headStart, 96), "r")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_6d83cef3e0cb19b8320a9c5feb26b56bbb08f152a8e61b12eca3302d8d68b23d__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 56)
        mstore(add(headStart, 64), "ERC721: approve caller is not ow")
        mstore(add(headStart, 96), "ner nor approved for all")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_c8682f3ad98807db59a6ec6bb812b72fed0a66e3150fa8239699ee83885247f2__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 49)
        mstore(add(headStart, 64), "ERC721: transfer caller is not o")
        mstore(add(headStart, 96), "wner nor approved")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_fd7d4525bec2f495f47e86138a1c7d65a91ba490ffac7499f8e60ae0841a827b__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 15)
        mstore(add(headStart, 64), "wrong hookCount")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_9924ebdf1add33d25d4ef888e16131f0a5687b0580a36c21b5c301a6c462effe__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 32)
        mstore(add(headStart, 64), "Ownable: caller is not the owner")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_1d7f5dcf03a65f41ee49b0ab593e3851cfbe3fd7da53b6cf4eddd83c7df5734c__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 43)
        mstore(add(headStart, 64), "ERC721Enumerable: owner index ou")
        mstore(add(headStart, 96), "t of bounds")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_ee6b7e810d7b317242d4688e6943ff4dd7897bb01d903b1a666812481b12a4f1__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 48)
        mstore(add(headStart, 64), "ERC721Burnable: caller is not ow")
        mstore(add(headStart, 96), "ner nor approved")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_d269a4e9f5820dcdb69ea21f528512eb9b927c8d846d48aa51c9219f461d4dcc__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 44)
        mstore(add(headStart, 64), "ERC721Enumerable: global index o")
        mstore(add(headStart, 96), "ut of bounds")
        tail := add(headStart, 128)
    }
    function panic_error_0x32()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x32)
        revert(0, 0x24)
    }
    function abi_encode_tuple_t_stringliteral_7a2a4e26842155ea933fe6eb6e3137eb5a296dcdf55721c552be7b4c3cc23759__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 46)
        mstore(add(headStart, 64), "Initializable: contract is alrea")
        mstore(add(headStart, 96), "dy initialized")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_7481f3df2a424c0755a1ad2356614e9a5a358d461ea2eae1f89cb21cbad00397__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 41)
        mstore(add(headStart, 64), "ERC721: owner query for nonexist")
        mstore(add(headStart, 96), "ent token")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_d858ee6fa318b093a0f671935061a7055f5d870ed7cbd06c33a5aca2b4066168__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 18)
        mstore(add(headStart, 64), "!onlyOwnerOrAuthor")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_uint256_t_address_t_uint64__to_t_uint256_t_address_t_uint64__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        mstore(headStart, value0)
        mstore(add(headStart, 32), and(value1, sub(shl(160, 1), 1)))
        mstore(add(headStart, 64), and(value2, 0xffffffffffffffff))
    }
    function abi_encode_tuple_t_stringliteral_7395d4d3901c50cdfcab223d072f9aa36241df5d883e62cbf147ee1b05a9e6ba__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 42)
        mstore(add(headStart, 64), "ERC721: balance query for the ze")
        mstore(add(headStart, 96), "ro address")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_407c81bc9d3414d25b7bf1a61ac25fdc6066a144da89b3125c22a249dd2bdd08__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 26)
        mstore(add(headStart, 64), "lengths should be the same")
        tail := add(headStart, 96)
    }
    function panic_error_0x11()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x11)
        revert(0, 0x24)
    }
    function increment_t_uint256(value) -> ret
    {
        if eq(value, not(0)) { panic_error_0x11() }
        ret := add(value, 1)
    }
    function abi_encode_tuple_t_stringliteral_45fe4329685be5ecd250fd0e6a25aea0ea4d0e30fb6a73c118b95749e6d70d05__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 25)
        mstore(add(headStart, 64), "ERC721: approve to caller")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_bytes4__to_t_bytes4__fromStack_reversed(headStart, value0) -> tail
    {
        tail := add(headStart, 32)
        mstore(headStart, and(value0, shl(224, 0xffffffff)))
    }
    function abi_decode_tuple_t_bool_fromMemory(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let value := mload(headStart)
        validator_revert_bool(value)
        value0 := value
    }
    function abi_encode_tuple_t_stringliteral_3b84fdf5d512cb81b9294fa36da46116206cc681c6018b31340df7b3bb3fa035__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 15)
        mstore(add(headStart, 64), "wrong interface")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_uint256_t_address__to_t_uint256_t_address__fromStack_reversed(headStart, value1, value0) -> tail
    {
        tail := add(headStart, 64)
        mstore(headStart, value0)
        mstore(add(headStart, 32), and(value1, sub(shl(160, 1), 1)))
    }
    function abi_encode_tuple_t_stringliteral_4d196e60019863795866dcd66219377a6a7d86cb348fad1cc6b1f62c21ff6687__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 15)
        mstore(add(headStart, 64), "already in sale")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_c423892000871cc52db900e0c02d28e9b7fb06acd0fc5fb25e1ddfa1643117de__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 19)
        mstore(add(headStart, 64), "invalid token owner")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_a27bcc4645f99d7350d87c430e841039dd871cc93aceca30fe9cd0808128f918__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 16)
        mstore(add(headStart, 64), "invalid duration")
        tail := add(headStart, 96)
    }
    function checked_add_t_uint64(x, y) -> sum
    {
        let _1 := 0xffffffffffffffff
        let x_1 := and(x, _1)
        let y_1 := and(y, _1)
        if gt(x_1, sub(_1, y_1)) { panic_error_0x11() }
        sum := add(x_1, y_1)
    }
    function abi_encode_tuple_t_stringliteral_ebf73bba305590e4764d5cb53b69bffd6d4d092d1a67551cb346f8cfcdab8619__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 31)
        mstore(add(headStart, 64), "ReentrancyGuard: reentrant call")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_b949dfdac5270ab5bb09607ca9d99e7b6eb368debb938cd60572750e2bd67659__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 20)
        mstore(add(headStart, 64), "token is not on sale")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_ada670740b39c655b6f43a000fe412152814f897521933a6327c4965f94bfc3f__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 23)
        mstore(add(headStart, 64), "wrong currency for sale")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_address_t_address__to_t_address_t_address__fromStack_reversed(headStart, value1, value0) -> tail
    {
        tail := add(headStart, 64)
        let _1 := sub(shl(160, 1), 1)
        mstore(headStart, and(value0, _1))
        mstore(add(headStart, 32), and(value1, _1))
    }
    function abi_decode_tuple_t_uint256_fromMemory(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        value0 := mload(headStart)
    }
    function abi_encode_tuple_t_stringliteral_26a26f7baa2b44f672b3df8584e81af135f94736a14e7fc9b0227fd23814f330__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 19)
        mstore(add(headStart, 64), "insufficient amount")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_address_t_address_t_uint256__to_t_address_t_address_t_uint256__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        let _1 := sub(shl(160, 1), 1)
        mstore(headStart, and(value0, _1))
        mstore(add(headStart, 32), and(value1, _1))
        mstore(add(headStart, 64), value2)
    }
    function checked_sub_t_uint256(x, y) -> diff
    {
        if lt(x, y) { panic_error_0x11() }
        diff := sub(x, y)
    }
    function abi_encode_tuple_t_stringliteral_a07542aa4da89b2bd2d564d8e740f31e45f7ab8b09d2fbf43bf45e297d7c8b9f__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 16)
        mstore(add(headStart, 64), "insufficient ETH")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_packed_t_bytes_memory_ptr__to_t_bytes_memory_ptr__nonPadded_inplace_fromStack_reversed(pos, value0) -> end
    {
        let length := mload(value0)
        copy_memory_to_memory(add(value0, 0x20), pos, length)
        end := add(pos, length)
    }
    function abi_encode_tuple_t_stringliteral_cabd2a6c8e2e4f596bab5005cda9be4282c85bc350737df39fa0abddc3ed844c__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 26)
        mstore(add(headStart, 64), "TRANSFER_COMMISSION_FAILED")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_4bbb3ad478d4dd4e0b8b0f9487de80c8c01790704a76f9d3e6e3a5cefcb4318f__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 24)
        mstore(add(headStart, 64), "TRANSFER_TO_OWNER_FAILED")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_8890e8cb922f6d582dba606e4b758c2c22c5e5d62c567f08a780b1dccbc48a11__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 13)
        mstore(add(headStart, 64), "REFUND_FAILED")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_8e9ed1638ba7e2d59e03d0957c9339381732ac84d73f65c86c45db1467eafa2a__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 49)
        mstore(add(headStart, 64), "ERC721URIStorage: URI query for ")
        mstore(add(headStart, 96), "nonexistent token")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_packed_t_string_memory_ptr__to_t_string_memory_ptr__nonPadded_inplace_fromStack_reversed(pos, value0) -> end
    {
        let length := mload(value0)
        copy_memory_to_memory(add(value0, 0x20), pos, length)
        end := add(pos, length)
    }
    function abi_encode_tuple_packed_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__to_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__nonPadded_inplace_fromStack_reversed(pos, value2, value1, value0) -> end
    {
        let length := mload(value0)
        copy_memory_to_memory(add(value0, 0x20), pos, length)
        let end_1 := add(pos, length)
        let length_1 := mload(value1)
        copy_memory_to_memory(add(value1, 0x20), end_1, length_1)
        let end_2 := add(end_1, length_1)
        let length_2 := mload(value2)
        copy_memory_to_memory(add(value2, 0x20), end_2, length_2)
        end := add(end_2, length_2)
    }
    function abi_encode_tuple_t_stringliteral_1f290f96783f53e78e482e0ab7e52a008c26e9e46032a57603df150a0d150381__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 18)
        mstore(add(headStart, 64), "COMMISSION_INVALID")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_a8e1aa610b18b2ebb04806310a0a09ec2061ccd732d489c9f0bc8f0182f09bd1__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 17)
        mstore(add(headStart, 64), "RECIPIENT_INVALID")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_245f15ff17f551913a7a18385165551503906a406f905ac1c2437281a7cd0cfe__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 38)
        mstore(add(headStart, 64), "Ownable: new owner is the zero a")
        mstore(add(headStart, 96), "ddress")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_47c416a9dcb6efd84b7e23af965b941aa01ae907087a168d27d408542552613c__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 22)
        mstore(add(headStart, 64), "can call only by owner")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_5797d1ccb08b83980dd0c07ea40d8f6a64d35fff736a19bdd17522954cb0899c__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 44)
        mstore(add(headStart, 64), "ERC721: operator query for nonex")
        mstore(add(headStart, 96), "istent token")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_a01073130a885d6c1c1af6ac75fc3b1c4f9403c235362962bbf528e2bd87d950__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 41)
        mstore(add(headStart, 64), "ERC721: transfer of token that i")
        mstore(add(headStart, 96), "s not own")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_455fea98ea03c32d7dd1a6f1426917d80529bf47b3ccbde74e7206e889e709f4__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 36)
        mstore(add(headStart, 64), "ERC721: transfer to the zero add")
        mstore(add(headStart, 96), "ress")
        tail := add(headStart, 128)
    }
    function checked_add_t_uint256(x, y) -> sum
    {
        if gt(x, not(y)) { panic_error_0x11() }
        sum := add(x, y)
    }
    function abi_encode_tuple_t_uint72_t_uint256_t_uint256__to_t_uint72_t_uint256_t_uint256__fromStack_reversed(headStart, value2, value1, value0) -> tail
    {
        tail := add(headStart, 96)
        mstore(headStart, and(value0, 0xffffffffffffffffff))
        mstore(add(headStart, 32), value1)
        mstore(add(headStart, 64), value2)
    }
    function abi_decode_tuple_t_uint256t_uint256_fromMemory(headStart, dataEnd) -> value0, value1
    {
        if slt(sub(dataEnd, headStart), 64) { revert(0, 0) }
        value0 := mload(headStart)
        value1 := mload(add(headStart, 32))
    }
    function return_data_selector() -> sig
    {
        if gt(returndatasize(), 3)
        {
            returndatacopy(0, 0, 4)
            sig := shr(224, mload(0))
        }
    }
    function try_decode_error_message() -> ret
    {
        if lt(returndatasize(), 0x44) { leave }
        let data := mload(64)
        let _1 := not(3)
        returndatacopy(data, 4, add(returndatasize(), _1))
        let offset := mload(data)
        let _2 := returndatasize()
        let _3 := 0xffffffffffffffff
        if or(gt(offset, _3), gt(add(offset, 0x24), _2)) { leave }
        let msg := add(data, offset)
        let length := mload(msg)
        if gt(length, _3) { leave }
        if gt(add(add(msg, length), 0x20), add(add(data, returndatasize()), _1)) { leave }
        finalize_allocation(data, add(add(offset, length), 0x20))
        ret := msg
    }
    function abi_encode_tuple_t_stringliteral_7780454945da99616b0f53a402cccf517489ef8cfd282e4a506befd0711d692f__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 41)
        mstore(add(headStart, 64), "Insufficient Utility Token: Cont")
        mstore(add(headStart, 96), "act Owner")
        tail := add(headStart, 128)
    }
    function abi_encode_tuple_t_stringliteral_1e766a06da43a53d0f4c380e06e5a342e14d5af1bf8501996c844905530ca84e__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 50)
        mstore(add(headStart, 64), "ERC721: transfer to non ERC721Re")
        mstore(add(headStart, 96), "ceiver implementer")
        tail := add(headStart, 128)
    }
    function checked_mul_t_uint256(x, y) -> product
    {
        if and(iszero(iszero(x)), gt(y, div(not(0), x))) { panic_error_0x11() }
        product := mul(x, y)
    }
    function checked_div_t_uint256(x, y) -> r
    {
        if iszero(y)
        {
            mstore(0, shl(224, 0x4e487b71))
            mstore(4, 0x12)
            revert(0, 0x24)
        }
        r := div(x, y)
    }
    function increment_t_int256(value) -> ret
    {
        if eq(value, sub(shl(255, 1), 1)) { panic_error_0x11() }
        ret := add(value, 1)
    }
    function abi_encode_tuple_t_stringliteral_3cbaa05f11e7d276f357ea99cada972749db83ddb8472fa4e750d5a96e002b21__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 23)
        mstore(add(headStart, 64), "Transfer Not Authorized")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_address_t_address_t_uint256_t_bytes_memory_ptr__to_t_address_t_address_t_uint256_t_bytes_memory_ptr__fromStack_reversed(headStart, value3, value2, value1, value0) -> tail
    {
        let _1 := sub(shl(160, 1), 1)
        mstore(headStart, and(value0, _1))
        mstore(add(headStart, 32), and(value1, _1))
        mstore(add(headStart, 64), value2)
        mstore(add(headStart, 96), 128)
        tail := abi_encode_string(value3, add(headStart, 128))
    }
    function abi_decode_tuple_t_bytes4_fromMemory(headStart, dataEnd) -> value0
    {
        if slt(sub(dataEnd, headStart), 32) { revert(0, 0) }
        let value := mload(headStart)
        validator_revert_bytes4(value)
        value0 := value
    }
    function abi_encode_tuple_t_stringliteral_8a66f4bb6512ffbfcc3db9b42318eb65f26ac15163eaa9a1e5cfa7bee9d1c7c6__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 32)
        mstore(add(headStart, 64), "ERC721: mint to the zero address")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_2a63ce106ef95058ed21fd07c42a10f11dc5c32ac13a4e847923f7759f635d57__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 28)
        mstore(add(headStart, 64), "ERC721: token already minted")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_stringliteral_aa5cab8e8eb38f50d8ce26d918c5e14bced666c7e74ed9dc2e48ba62a7f1b78e__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 19)
        mstore(add(headStart, 64), "exceed series limit")
        tail := add(headStart, 96)
    }
    function abi_encode_tuple_t_address_t_uint256__to_t_address_t_uint256__fromStack_reversed(headStart, value1, value0) -> tail
    {
        tail := add(headStart, 64)
        mstore(headStart, and(value0, sub(shl(160, 1), 1)))
        mstore(add(headStart, 32), value1)
    }
    function checked_mul_t_int256(x, y) -> product
    {
        let _1 := sub(shl(255, 1), 1)
        let _2 := sgt(y, 0)
        let _3 := sgt(x, 0)
        if and(and(_3, _2), gt(x, div(_1, y))) { panic_error_0x11() }
        let _4 := shl(255, 1)
        let _5 := slt(y, 0)
        if and(and(_3, _5), slt(y, sdiv(_4, x))) { panic_error_0x11() }
        let _6 := slt(x, 0)
        if and(and(_6, _2), slt(x, sdiv(_4, y))) { panic_error_0x11() }
        if and(and(_6, _5), slt(x, sdiv(_1, y))) { panic_error_0x11() }
        product := mul(x, y)
    }
    function checked_sub_t_int256(x, y) -> diff
    {
        let _1 := slt(y, 0)
        if and(iszero(_1), slt(x, add(shl(255, 1), y))) { panic_error_0x11() }
        if and(_1, sgt(x, add(sub(shl(255, 1), 1), y))) { panic_error_0x11() }
        diff := sub(x, y)
    }
    function decrement_t_int256(value) -> ret
    {
        if eq(value, shl(255, 1)) { panic_error_0x11() }
        ret := add(value, not(0))
    }
    function abi_encode_tuple_t_stringliteral_04fc88320d7c9f639317c75102c103ff0044d3075a5c627e24e76e5bbb2733c2__to_t_string_memory_ptr__fromStack_reversed(headStart) -> tail
    {
        mstore(headStart, 32)
        mstore(add(headStart, 32), 32)
        mstore(add(headStart, 64), "Strings: hex length insufficient")
        tail := add(headStart, 96)
    }
    function panic_error_0x31()
    {
        mstore(0, shl(224, 0x4e487b71))
        mstore(4, 0x31)
        revert(0, 0x24)
    }
}