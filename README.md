# ⚖️ Court Ruling NFT System

A blockchain-based solution for creating immutable, transparent, and accessible court ruling records as Non-Fungible Tokens (NFTs) on the Stacks blockchain.

## 🎯 Overview

The Court Ruling NFT System addresses the critical problems of fragmented, censored, or inaccessible court records by:

- 🏛️ Minting court rulings as NFTs with comprehensive metadata
- 🔒 Storing rulings immutably on the blockchain
- 🌐 Providing public or restricted access controls
- 📚 Creating permanent reference archives for legal professionals
- 🔍 Enabling integration with digital legal libraries

## ✨ Key Features

### 🔐 Access Control
- **Contract Owner**: Full administrative control
- **Authorized Minters**: Designated entities who can mint new rulings
- **Restricted Access**: Sensitive rulings can be marked as restricted

### 📝 Court Ruling Data
Each NFT contains comprehensive ruling information:
- Case number and court name
- Plaintiff and defendant information
- Judge name and ruling date
- Detailed ruling summary
- Case type classification
- Cryptographic hash for verification
- Creation timestamp and creator

### 🛠️ Core Functions
- **Mint Rulings**: Create new court ruling NFTs
- **Transfer**: Move ownership between parties
- **Metadata Management**: Update ruling metadata
- **Access Controls**: Manage restricted access
- **Verification**: Verify ruling authenticity via hash

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/stacks/clarinet) installed
- Stacks wallet for deployment

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd Court-Ruling-NFT-System
```

2. Install dependencies:
```bash
npm install
```

3. Check contract validity:
```bash
clarinet check
```

4. Run tests:
```bash
npm test
```

## 📋 Usage Examples

### Minting a Court Ruling

```clarity
(contract-call? .court-ruling-nft-system mint-ruling
  'SP1RECIPIENT...
  "CASE-2024-001"
  "Supreme Court of Example"
  "John Doe"
  "Jane Smith"
  "Hon. Judge Wilson"
  u20240115
  "The court rules in favor of the plaintiff..."
  "Civil"
  0x1234567890abcdef...
  "public"
  u"{\"description\": \"Landmark civil rights case...\"}")
```

### Retrieving Ruling Data

```clarity
(contract-call? .court-ruling-nft-system get-ruling-data u1)
```

### Verifying a Ruling

```clarity
(contract-call? .court-ruling-nft-system verify-ruling-hash 
  u1 
  0x1234567890abcdef...)
```

## 🔧 Contract Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `mint-ruling` | 📝 Create a new court ruling NFT |
| `transfer` | 🔄 Transfer NFT ownership |
| `add-authorized-minter` | ➕ Add authorized minter |
| `remove-authorized-minter` | ➖ Remove authorized minter |
| `update-ruling-metadata` | 📝 Update metadata |
| `set-restricted-access` | 🔒 Control access restrictions |
| `pause-contract` | ⏸️ Emergency pause |
| `unpause-contract` | ▶️ Resume operations |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-ruling-data` | 📊 Get complete ruling information |
| `get-ruling-metadata` | 🏷️ Get metadata |
| `get-owner` | 👤 Get NFT owner |
| `get-last-token-id` | 🔢 Get latest token ID |
| `get-token-by-case-number` | 🔍 Find token by case number |
| `verify-ruling-hash` | ✅ Verify ruling authenticity |
| `is-authorized-minter` | ✅ Check minter authorization |

## 🏗️ Architecture

```
Court Ruling NFT System
├── NFT Definition (court-ruling)
├── Data Storage
│   ├── Court Rulings Map
│   ├── Metadata Map
│   ├── Case-to-Token Map
│   └── Access Control Maps
├── Access Control
│   ├── Contract Owner
│   ├── Authorized Minters
│   └── Restricted Access
└── Functions
    ├── Administrative
    ├── Minting & Transfer
    └── Query & Verification
```

## 🔒 Security Features

- **Multi-level Access Control**: Owner, authorized minters, and public access
- **Input Validation**: Comprehensive parameter checking
- **Immutable Records**: Once minted, core ruling data cannot be changed
- **Hash Verification**: Cryptographic verification of ruling integrity
- **Emergency Controls**: Contract pause functionality

## 🌐 Use Cases

### Legal Professionals
- 📖 Access historical case law
- 🔍 Research legal precedents
- ✅ Verify ruling authenticity

### Citizens & Researchers
- 🏛️ Public transparency in judiciary
- 📊 Legal system analysis
- 📚 Academic research

### Courts & Institutions
- 🗄️ Digital record keeping
- 🔐 Secure document storage
- 🌐 Inter-jurisdictional sharing

## 📈 Future Enhancements

- 🔍 Advanced search functionality
- 📊 Analytics dashboard
- 🔗 Integration with legal databases
- 📱 Mobile application
- 🌍 Multi-jurisdictional support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `npm test`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- 📧 Open an issue on GitHub
- 📚 Check the [Stacks Documentation](https://docs.stacks.co/)
- 💬 Join the [Stacks Discord](https://discord.gg/stacks)

---

*Building a more transparent and accessible judicial system, one ruling at a time.* ⚖️✨
