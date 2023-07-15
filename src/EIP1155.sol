// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

// implementation for https://eips.ethereum.org/EIPS/eip-1155

abstract contract ERC1155TokenReceiver {
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        virtual
        returns (bytes4)
    {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}

abstract contract ERC1155 {
    mapping(address => mapping(uint256 => uint256)) balanceOf;
    mapping(address => mapping(address => bool)) isApprovalForAll;

    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );

    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function tokenURI(uint256 id) public view virtual returns (string memory);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
        public
        virtual
    {
        require(balanceOf[_from][_id] >= _value, "InsufficientBalance");
        require(_from == msg.sender || isApprovalForAll[_from][msg.sender], "InvalidAuthority");
        unchecked {
            balanceOf[_from][_id] -= _value;
        }
        balanceOf[_to][_id] += _value;
        emit TransferSingle(msg.sender, _from, _to, _id, _value);
        require(
            _to.code.length == 0
                || ERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _value, _data)
                    == ERC1155TokenReceiver.onERC1155Received.selector,
            "UnsafeRecipient"
        );
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) public virtual {
        require(_ids.length == _values.length, "Invalid ids or values");
        require(_from == msg.sender || isApprovalForAll[_from][msg.sender], "InvalidAuthority");
        for (uint256 i = 0; i < _ids.length; i++) {
            balanceOf[_from][_ids[i]] -= _values[i];
            balanceOf[_to][_ids[i]] += _values[i];
        }
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
        require(
            _to.code.length == 0
                || ERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _values, _data)
                    == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UnsafeRecipient"
        );
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(_owners.length == _ids.length, "InvalidIdsOrOwners");
        balances = new uint256[](_ids.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            balances[i] = balanceOf[_owners[i]][_ids[i]];
        }
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual {
        isApprovalForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(
            to != address(0) || to.code.length == 0
                || ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data)
                    == ERC1155TokenReceiver.onERC1155Received.selector,
            "UnsafeRecipient"
        );
        balanceOf[to][id] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        virtual
    {
        require(ids.length == amounts.length, "InlvalidIdsOrAmounts");
        require(
            to != address(0) || to.code.length == 0
                || ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data)
                    == ERC1155TokenReceiver.onERC1155Received.selector,
            "UnsafeRecipient"
        );
        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[to][ids[i]] += amounts[i];
        }
    }

    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(balanceOf[from][id] >= amount, "InsufficientBalance");
        require(from == msg.sender || isApprovalForAll[from][msg.sender], "InvalidAuthority");
        unchecked {
            balanceOf[from][id] -= amount;
        }
        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }

    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(ids.length == amounts.length, "InlvalidIdsOrAmounts");
        for (uint256 i = 0; i < ids.length; i++) {
            balanceOf[from][ids[i]] -= amounts[i];
        }
        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function supportInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 //ERC165
            || interfaceId == 0xd9b67a26 //ERC1155
            || interfaceId == 0x0e89341c; //ERC1155MetadataURI
    }
}
