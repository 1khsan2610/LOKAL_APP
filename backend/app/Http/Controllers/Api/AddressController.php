<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Address;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function index()
    {
        return response()->json(['success' => true, 'data' => Address::where('user_id', auth()->id())->orderBy('is_default','desc')->get()]);
    }

    public function show($id)
    {
        $address = Address::where('user_id', auth()->id())->findOrFail($id);
        return response()->json(['success' => true, 'data' => $address]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'label'          => 'nullable|string|max:50',
            'recipient_name' => 'required|string|max:100',
            'phone'          => 'required|string|max:20',
            'detail'         => 'required|string',
            'city'           => 'required|string|max:50',
            'province'       => 'required|string|max:50',
            'zip'            => 'required|string|max:10',
        ]);

        // If first address, set as default
        $isDefault = Address::where('user_id', auth()->id())->count() === 0;
        if ($request->is_default) {
            Address::where('user_id', auth()->id())->update(['is_default' => false]);
            $isDefault = true;
        }

        $address = Address::create([
            'user_id'        => auth()->id(),
            'label'          => $request->label ?? 'Rumah',
            'recipient_name' => $request->recipient_name,
            'phone'          => $request->phone,
            'detail'         => $request->detail,
            'city'           => $request->city,
            'province'       => $request->province,
            'zip'            => $request->zip,
            'is_default'     => $isDefault,
        ]);

        return response()->json(['success' => true, 'message' => 'Alamat berhasil ditambahkan.', 'data' => $address], 201);
    }

    public function update(Request $request, $id)
    {
        $address = Address::where('user_id', auth()->id())->findOrFail($id);
        $address->update($request->only(['label','recipient_name','phone','detail','city','province','zip']));
        return response()->json(['success' => true, 'message' => 'Alamat diperbarui.', 'data' => $address]);
    }

    public function destroy($id)
    {
        Address::where('user_id', auth()->id())->findOrFail($id)->delete();
        return response()->json(['success' => true, 'message' => 'Alamat dihapus.']);
    }

    public function setDefault($id)
    {
        Address::where('user_id', auth()->id())->update(['is_default' => false]);
        Address::where('user_id', auth()->id())->findOrFail($id)->update(['is_default' => true]);
        return response()->json(['success' => true, 'message' => 'Alamat utama diperbarui.']);
    }
}
