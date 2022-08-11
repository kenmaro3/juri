import { simplifiedFetch } from '../../../core/services/simplifiedFetch'

import { decodeBase64 } from '../../../core/services/decodeBase64'

export const createPublicKeyCredential = async (username: string) => {
  // get random generated challenge
  let urlParams = new URLSearchParams({
    username,
  })
  const preCredential = await simplifiedFetch(
    `/api/register?${urlParams}`,
    {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    }
  )

  console.log('preCredential', preCredential)

  // build option
  const publicKeyCredentialCreationOptions: PublicKeyCredentialCreationOptions =
    {
      challenge: decodeBase64(preCredential.data.challenge),
      rp: preCredential.data.rp,
      // rp: {
      //   name: 'RAYRIFFY',
      //   id: 'rayriffy.com',
      // },
      user: {
        id: decodeBase64(preCredential.data.uid),
        name: username.toLowerCase(),
        displayName: username.toLowerCase(),
      },
      pubKeyCredParams: [
        /**
         * https://www.w3.org/TR/webauthn-2/#typedefdef-cosealgorithmidentifier
         */

        // ES256: ECDSA with SHA256
        { alg: -7, type: 'public-key' },
        // RS256: RSA Signature with SHA256
        { alg: -257, type: 'public-key' },
      ],
      authenticatorSelection: {
        userVerification: 'preferred',
        requireResidentKey: false,
      },
      attestation: 'direct',
    }

  console.log(
    'publicKeyCredentialCreationOptions',
    publicKeyCredentialCreationOptions
  )
  // request credential
  return navigator.credentials.create({
    publicKey: publicKeyCredentialCreationOptions,
  }) as Promise<PublicKeyCredential | null>
}
