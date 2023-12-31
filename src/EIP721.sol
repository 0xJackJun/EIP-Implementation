// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

// implementation for https://eips.ethereum.org/EIPS/eip-721

abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;
    string public symbol;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                            EVENT
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /*//////////////////////////////////////////////////////////////
                            ERC721 INTERFACE
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 tokenID) public view virtual returns (string memory);

    function approve(address _approved, uint256 _tokenId) public payable virtual {
        address owner = ownerOf[_tokenId];
        require(owner == msg.sender || isApprovedForAll[owner][msg.sender] == true, "NotAuthorized");
        getApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual {
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable virtual {
        require(ownerOf[_tokenId] == _from, "InvalidFrom");
        require(_to != address(0), "InvalidRecipient");
        require(
            _from == msg.sender || getApproved[_tokenId] == msg.sender || isApprovedForAll[_from][msg.sender],
            "NotAuthorized"
        );
        balanceOf[_from]--;
        balanceOf[_to]++;
        ownerOf[_tokenId] = _to;
        delete getApproved[_tokenId];
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable virtual {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
        transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data)
        external
        payable
        virtual
    {
        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
        transferFrom(_from, _to, _tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

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
        require(ownerOf[id] == address(0), "Already Minted");
        ownerOf[id] = to;
        balanceOf[to]++;
        emit Transfer(address(0), to, id);
    }

    function _burn(address from, uint256 id) internal virtual {
        require(ownerOf[id] == from || getApproved[id] == msg.sender || isApprovedForAll[from][msg.sender] == true, "NotAuthorized");
        delete ownerOf[id];
        balanceOf[from]--;
        delete getApproved[id];
        emit Transfer(from, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                            EIP165 FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 //ERC165
            || interfaceId == 0x80ac58cd //ERC721
            || interfaceId == 0x5b5e139f; //ERC721Metadata
    }
}
