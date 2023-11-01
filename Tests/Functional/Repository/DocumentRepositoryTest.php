<?php

namespace Kitodo\Dlf\Tests\Functional\Repository;

use Kitodo\Dlf\Common\AbstractDocument;
use Kitodo\Dlf\Common\MetsDocument;
use Kitodo\Dlf\Domain\Repository\DocumentRepository;
use Kitodo\Dlf\Tests\Functional\FunctionalTestCase;
use TYPO3\CMS\Extbase\Persistence\Generic\LazyObjectStorage;

class DocumentRepositoryTest extends FunctionalTestCase
{
    /**
     * @var DocumentRepository
     */
    protected $documentRepository;

    public function setUp(): void
    {
        parent::setUp();

        $this->documentRepository = $this->initializeRepository(DocumentRepository::class, 20000);

        $this->importCSVDataSet(__DIR__ . '/../../Fixtures/Common/documents_1.csv');
        $this->importDataSet(__DIR__ . '/../../Fixtures/Common/pages.xml');
        $this->importCSVDataSet(__DIR__ . '/../../Fixtures/Common/libraries.csv');
    }

    /**
     * @test
     */
    public function canRetrieveDocument(): void
    {
        $document = $this->documentRepository->findByUid(1001);
        self::assertNotNull($document);
        self::assertEquals('METS', $document->getDocumentFormat());
        self::assertNotEmpty($document->getTitle());
        self::assertEquals('Default Library', $document->getOwner()->getLabel());

        $doc = AbstractDocument::getInstance($document->getLocation());
        self::assertInstanceOf(MetsDocument::class, $doc);
    }

    /**
     * @test
     */
    public function canFindOldestDocument(): void
    {
        $document = $this->documentRepository->findOldestDocument();
        self::assertNotNull($document);
        self::assertEquals(1002, $document->getUid());
    }

    /**
     * @test
     */
    public function canGetCollectionsOfDocument(): void
    {
        $document = $this->documentRepository->findByUid(1001);
        $collections = $document->getCollections();
        self::assertInstanceOf(LazyObjectStorage::class, $collections);

        $collectionsByLabel = [];
        foreach ($collections as $collection) {
            $collectionsByLabel[$collection->getLabel()] = $collection;
        }

        self::assertArrayHasKey('Musik', $collectionsByLabel);
    }
}
