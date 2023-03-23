pragma solidity >=0.4.25 <0.9.0;

//import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

// imports from open zeppelin
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract myERC is ERC165, IERC721, IERC721Metadata, Ownable {
  using Counters for Counters.Counter;
  using Address for address;
  using Strings for uint256;

  Counters.Counter private _tokenIdCounter;
  string private _name;
  string private _symbol;

  mapping(uint256 => address) private _owners;
  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  constructor(){
    _name = 'myERC';
    _symbol = 'MERC';
  }

  function name() public view virtual override (IERC721Metadata) returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override (IERC721Metadata) returns (string memory) {
    return _symbol;
  }

  function balanceOf(address owner) public view virtual override (IERC721) returns (uint256) {
    require(owner != address(0), "ERC721: address zero is not a valid owner");
    return _balances[owner];
  }

  function ownerOf(uint256 tokenId) public view virtual override (IERC721) returns (address) {
    address owner = _ownerOf(tokenId);
    require(owner != address(0), "ERC721: invalid token ID");
    return owner;
  }

  function safeMint(address to) public onlyOwner {
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(to, tokenId);
    //_setTokenURI(tokenId, uri);
  }

  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
    _mint(to, tokenId);
    require(
      _checkOnERC721Received(address(0), to, tokenId, data),
      "ERC721: transfer to non ERC721Receiver implementer"
    );
  }

  function _mint(address to, uint256 tokenId) internal virtual {
    require(to != address(0), "ERC721: mint to zero address");
    require(!_exists(tokenId), "ERC721: token already minted");


    //require(!_exists(tokenId), "ERC721: token already minted");

    unchecked {
      _balances[to] += 1;
    }

    _owners[tokenId] = to;

    emit Transfer(address(0), to, tokenId);
  }

  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _ownerOf(tokenId) != address(0);
  }

  function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
    return _owners[tokenId];
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override (IERC721) {
    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override (IERC721) {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
    _safeTransfer(from, to, tokenId, data);
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    address owner = _ownerOf(tokenId);
    return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
  }

  function isApprovedForAll(address owner, address operator) public view virtual override (IERC721) returns (bool) {
    return _operatorApprovals[owner][operator];
  }

  function getApproved(uint256 tokenId) public view virtual override (IERC721) returns (address) {
    _requireMinted(tokenId);
    return _tokenApprovals[tokenId];
  }

  function _requireMinted(uint256 tokenId) internal view virtual {
    require(_exists(tokenId), "ERC721: invalid token ID");
  }

  function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
    _transfer(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
  }

  function _transfer(address from, address to, uint256 tokenId) internal virtual {
    require(_ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
    require(to != address(0), "ERC721: transfer to the zero address");

    delete _tokenApprovals[tokenId];

    unchecked {
      _balances[from] -= 1;
      _balances[to] += 1;
    }
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  function _checkOnERC721Received(
    address from, address to, uint256 tokenId, bytes memory data)
    private returns (bool) {
      if(to.isContract()) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
          return retval == IERC721Receiver.onERC721Received.selector;
        } catch (bytes memory reason) {
          if (reason.length == 0) {
            revert("ERC721: transfer to non ERC721Receiver implementer");
          } else {
            assembly {
              revert(add(32, reason), mload(reason))
            }
          }
        }
      } else {
        return true;
      }
    }
  
  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
    _transfer(from, to, tokenId);
  }

  function approve(address to, uint256 tokenId) public virtual override (IERC721) {
    address owner = _ownerOf(tokenId);
    require (to != owner, "ERC721: approval to current owner");

    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721: approve caller is not token owner or approved for all"
    );

    _approve(to, tokenId);
  }

  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(_ownerOf(tokenId), to, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) public virtual override (IERC721) {
    _setApprovalForAll(_msgSender(), operator, approved);
  }

  function _setApprovalForAll(address owner, address operator, bool approved) internal virtual{
    require(owner != operator, "ERC721: approve to caller");
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }
  
  function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
    return 
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function _burn(uint256 tokenId) internal virtual {
    address owner = _ownerOf(tokenId);

    owner = _ownerOf(tokenId);

    delete _tokenApprovals[tokenId];

    unchecked {
      _balances[owner] -= 1;
    }
    
    delete _owners[tokenId];

    emit Transfer(owner, address(0), tokenId);
  }

  function _baseURI() internal view virtual returns (string memory) {
    return "https://gateway.pinata.cloud/ipfs/QmXrssTbcf7fUL5vAgFmT8D5W7VgVFBpv3a89XgNpxSDaH";
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(IERC721Metadata)
    returns (string memory) {
      _requireMinted(tokenId);
      string memory baseURI = _baseURI();
      return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

  
}// end of contract
