use std::ptr;
use windows_sys::Win32::Foundation::LocalFree;
use windows_sys::Win32::Security::Cryptography::{
    CryptProtectData, CryptUnprotectData, CRYPTPROTECT_UI_FORBIDDEN, CRYPT_INTEGER_BLOB,
};

/// Encrypts plaintext using Windows DPAPI (CryptProtectData).
/// Returns Base64-encoded ciphertext tied to the current Windows user account.
pub fn encrypt_string(plaintext: &str) -> Result<String, String> {
    if plaintext.is_empty() {
        return Ok(String::new());
    }

    let bytes = plaintext.as_bytes();
    let in_blob = CRYPT_INTEGER_BLOB {
        cbData: bytes.len() as u32,
        pbData: bytes.as_ptr() as *mut u8,
    };
    let mut out_blob = CRYPT_INTEGER_BLOB {
        cbData: 0,
        pbData: ptr::null_mut(),
    };

    unsafe {
        let success = CryptProtectData(
            &in_blob,
            ptr::null(),
            ptr::null(),
            ptr::null(),
            ptr::null(),
            CRYPTPROTECT_UI_FORBIDDEN,
            &mut out_blob,
        );

        if success == 0 || out_blob.pbData.is_null() {
            return Err("Failed to encrypt data with Windows DPAPI".into());
        }

        let encrypted_slice = std::slice::from_raw_parts(out_blob.pbData, out_blob.cbData as usize);
        let base64_encoded = custom_base64_encode(encrypted_slice);

        LocalFree(out_blob.pbData as _);
        Ok(base64_encoded)
    }
}

/// Decrypts Base64 ciphertext using Windows DPAPI (CryptUnprotectData).
pub fn decrypt_string(encrypted_base64: &str) -> Result<String, String> {
    if encrypted_base64.is_empty() {
        return Ok(String::new());
    }

    let ciphertext = custom_base64_decode(encrypted_base64)
        .ok_or_else(|| "Invalid Base64 ciphertext in settings".to_string())?;

    let in_blob = CRYPT_INTEGER_BLOB {
        cbData: ciphertext.len() as u32,
        pbData: ciphertext.as_ptr() as *mut u8,
    };
    let mut out_blob = CRYPT_INTEGER_BLOB {
        cbData: 0,
        pbData: ptr::null_mut(),
    };

    unsafe {
        let success = CryptUnprotectData(
            &in_blob,
            ptr::null_mut(),
            ptr::null(),
            ptr::null(),
            ptr::null(),
            CRYPTPROTECT_UI_FORBIDDEN,
            &mut out_blob,
        );

        if success == 0 || out_blob.pbData.is_null() {
            return Err("Failed to decrypt data with Windows DPAPI".into());
        }

        let decrypted_slice = std::slice::from_raw_parts(out_blob.pbData, out_blob.cbData as usize);
        let text = String::from_utf8(decrypted_slice.to_vec())
            .map_err(|e| format!("Decrypted bytes are not valid UTF-8: {}", e))?;

        LocalFree(out_blob.pbData as _);
        Ok(text)
    }
}

// Minimal fast standard Base64 helpers without extra external crate
const B64_CHARS: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

fn custom_base64_encode(input: &[u8]) -> String {
    let mut buf = String::with_capacity((input.len() + 2) / 3 * 4);
    for chunk in input.chunks(3) {
        let b0 = chunk[0];
        let b1 = if chunk.len() > 1 { chunk[1] } else { 0 };
        let b2 = if chunk.len() > 2 { chunk[2] } else { 0 };

        buf.push(B64_CHARS[((b0 >> 2) & 0x3F) as usize] as char);
        buf.push(B64_CHARS[(((b0 & 0x03) << 4) | ((b1 >> 4) & 0x0F)) as usize] as char);
        if chunk.len() > 1 {
            buf.push(B64_CHARS[(((b1 & 0x0F) << 2) | ((b2 >> 6) & 0x03)) as usize] as char);
        } else {
            buf.push('=');
        }
        if chunk.len() > 2 {
            buf.push(B64_CHARS[(b2 & 0x3F) as usize] as char);
        } else {
            buf.push('=');
        }
    }
    buf
}

fn custom_base64_decode(input: &str) -> Option<Vec<u8>> {
    let mut table = [255u8; 256];
    for (i, &c) in B64_CHARS.iter().enumerate() {
        table[c as usize] = i as u8;
    }

    let input_clean: Vec<u8> = input.bytes().filter(|b| !b.is_ascii_whitespace()).collect();
    if input_clean.is_empty() {
        return Some(Vec::new());
    }
    if input_clean.len() % 4 != 0 {
        return None;
    }

    let mut out = Vec::with_capacity(input_clean.len() / 4 * 3);
    for chunk in input_clean.chunks(4) {
        let c0 = table[chunk[0] as usize];
        let c1 = table[chunk[1] as usize];
        let c2 = if chunk[2] == b'=' { 0 } else { table[chunk[2] as usize] };
        let c3 = if chunk[3] == b'=' { 0 } else { table[chunk[3] as usize] };

        if c0 == 255 || c1 == 255 || (chunk[2] != b'=' && c2 == 255) || (chunk[3] != b'=' && c3 == 255) {
            return None;
        }

        out.push((c0 << 2) | (c1 >> 4));
        if chunk[2] != b'=' {
            out.push((c1 << 4) | (c2 >> 2));
        }
        if chunk[3] != b'=' {
            out.push((c2 << 6) | c3);
        }
    }
    Some(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dpapi_roundtrip() {
        let secret = "AIzaSyTestApiKey12345";
        let encrypted = encrypt_string(secret).expect("encrypt failed");
        assert_ne!(secret, encrypted);
        let decrypted = decrypt_string(&encrypted).expect("decrypt failed");
        assert_eq!(secret, decrypted);
    }
}
