                          // --- 1. Select Payout Method Dropdown Input ---
                          const Text('Select Payout Method', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1A1A1E),
                            style: const TextStyle(color: Colors.white),
                            value: _selectedMethod,
                            hint: const Text('Choose payment channel', style: TextStyle(color: Colors.grey)),
                            items: _payoutMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                            onChanged: (val) => setState(() => _selectedMethod = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 2. Contextual Conditional Promo Block (UNO Wallet) ---
                          if (_selectedMethod == 'UNO Wallet') ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📌 Join One and grab a ₱100 bonus! Use code V98HAR on signup. Register through: https://uno.global',
                                    style: TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // --- 3. Account Number / Identifier Input ---
                          const Text('Account Number / Identifier', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNumberController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number or email ID',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Account identifier cannot be blank' : null,
                          ),
                          const SizedBox(height: 16),

                          // --- 4. Recipient Registered Name Input ---
                          const Text('Recipient Registered Name', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _accountNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter your full legal name',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Legal beneficiary name required' : null,
                          ),
                          const SizedBox(height: 24),
