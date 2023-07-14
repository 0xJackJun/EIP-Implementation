// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

// implementation for https://eips.ethereum.org/EIPS/eip-721

abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

abstract contract ERC721 {
    string public name;
    string public symbol;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    error NotAuthorized();
    error InvalidFrom();
    error InvalidRecipient();

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function approve(address _approved, uint256 _tokenId) public payable virtual {
        if (ownerOf[_tokenId] != msg.sender || isApprovedForAll[msg.sender][_approved] != true) revert NotAuthorized();
        getApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual {
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable virtual {
        if (ownerOf[_tokenId] != _from) revert InvalidFrom();
        if (_to == address(0)) revert InvalidRecipient();
        if (_from != msg.sender && getApproved[_tokenId] != msg.sender && !isApprovedForAll[_from][msg.sender]) {
            revert NotAuthorized();
        }
        balanceOf[_from] -= 1;
        balanceOf[_to] += 1;
        ownerOf[_tokenId] = _to;
        delete getApproved[_tokenId];
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable virtual {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "Unsafe_Recipient"
        );
        transferFrom(_from, _to, _tokenId);
    }

    function tokenURI(uint256 tokenID) public view virtual returns (string memory);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data)
        external
        payable
        virtual
    {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "Unsafe_Recipient"
        );
        transferFrom(_from, _to, _tokenId);
    }

    function _safeMint(address _to, uint256 _tokenId) internal virtual {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, address(0), _tokenId, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
        _mint(_to, _tokenId);
    }

    function _safeMint(address _to, uint256 _tokenId, bytes calldata data) internal virtual {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, address(0), _tokenId, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
        _mint(_to, _tokenId);
    }

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "Invalid_Recipient");
        ownerOf[id] = to;
        balanceOf[to]++;
        emit Transfer(address(0), to, id);
    }

    function _burn(address from, uint256 id) internal virtual {
        require(ownerOf[id] == from, "NotAuthorized");
        delete ownerOf[id];
        balanceOf[from]--;
        delete getApproved[id];
        emit Transfer(from, address(0), id);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 //ERC165
            || interfaceId == 0x80ac58cd //ERC721
            || interfaceId == 0x5b5e139f; //ERC721Metadata
    }
}
