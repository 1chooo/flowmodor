import { Link } from '@nextui-org/react';
import Image from 'next/image';

export default function SignLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <Link
        href="https://flowmodor.com"
        className="absolute left-5 top-5 flex items-center gap-2 text-white sm:left-10 sm:top-10"
      >
        <Image
          src="/images/logo.png"
          alt="logo"
          unoptimized
          width={56}
          height={56}
        />
        <h1 className="text-2xl font-bold">Flowmodor</h1>
      </Link>
      {children}
    </>
  );
}