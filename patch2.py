# coding=utf-8
import os

file_path = r'c:\Users\pojot\StudioProjects\Pojo Infra360\lib\view\material_category\material_request\material_request_list_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

funcs = '''
  Widget _headerCell(String title, {required int flex, TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: textAlign,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    MaterialRequestItem item,
    int index,
    MaterialRequestListController controller,
  ) {
    final bool isPending = (item.status ?? '').toLowerCase() == 'pending';
    final bool isApproved = (item.status ?? '').toLowerCase() == 'approved';
    final bool isRejected = (item.status ?? '').toLowerCase() == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S.No: \',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF252C58), fontSize: 14),
              ),
              _buildStatusBadge(item.status ?? 'pending'),
            ],
          ),
          const SizedBox(height: 12),
          _buildCardRow('Material / Item', item.materialItem ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Quantity', item.quantity ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Unit', item.unit ?? ''),
          const SizedBox(height: 8),
          _buildCardRow('Needed By', _formatDate(item.neededBy)),
          const SizedBox(height: 8),
          _buildCardRow('Vendor', item.vendorName ?? ''),
          const SizedBox(height: 8),
          
          const Text('Remarks', style: TextStyle(color: Color(0xFF6E6B7B), fontSize: 13)),
          const SizedBox(height: 4),
          Text(item.remarks ?? 'N/A', style: const TextStyle(color: Color(0xFF252C58), fontSize: 14)),
          
          if (isRejected && item.adminRemark != null && item.adminRemark!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Rejection reason: \", style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          if (isApproved || isRejected)
            Align(
              alignment: Alignment.centerRight,
              child: Text(_timeAgo(item.reviewedAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            )
          else if (isPending)
            _isAdmin
                ? Obx(() => controller.isActioning.value
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _actionButton(
                            label: "Approve",
                            icon: Icons.check,
                            color: Colors.green,
                            onTap: () => _confirmAction(
                              context,
                              title: "Approve Request",
                              message: "Are you sure you want to approve this material request?",
                              confirmLabel: "Approve",
                              confirmColor: Colors.green,
                              onConfirm: () => controller.approveRequest(item.id!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _actionButton(
                            label: "Reject",
                            icon: Icons.close,
                            color: Colors.red,
                            onTap: () => _showRejectDialog(
                              context,
                              onConfirm: (String? remark) =>
                                  controller.rejectRequest(item.id!, adminRemark: remark),
                            ),
                          ),
                        ],
                      ))
                : const Align(
                    alignment: Alignment.centerRight,
                    child: Text("Pending Review", style: TextStyle(color: Colors.grey)),
                  )
          else
             const Align(
                alignment: Alignment.centerRight,
                child: Text("-", style: TextStyle(color: Colors.grey)),
              ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6E6B7B), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF252C58), fontSize: 14)),
      ],
    );
  }
'''

new_content = content.rstrip()
if new_content.endswith('}'):
    new_content = new_content[:-1] + funcs + '\\n}'

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Patched material_request_list_screen.dart")
